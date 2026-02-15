#!/usr/bin/env bash
set -euo pipefail

# Fetches a GitHub Actions OIDC token, discovers all AWS accounts via
# Organizations API, and generates ~/.aws/config with a named profile
# per account. Each profile assumes the github-actions OIDC role.
#
# Requires:
#   - ACTIONS_ID_TOKEN_REQUEST_URL and ACTIONS_ID_TOKEN_REQUEST_TOKEN (set by GitHub Actions when id-token: write is granted)
#   - AWS_ROOT_ACCOUNT_ID environment variable (management account ID)

if [[ -z "${AWS_ROOT_ACCOUNT_ID:-}" ]]; then
  echo "::error::AWS_ROOT_ACCOUNT_ID is not set"
  exit 1
fi

if [[ -z "${ACTIONS_ID_TOKEN_REQUEST_URL:-}" ]]; then
  echo "::error::OIDC token request URL not available. Ensure id-token: write permission is set."
  exit 1
fi

REGION="us-west-2"
ROLE_PATH="service/github-actions"
TOKEN_FILE="${RUNNER_TEMP}/oidc-token"

# Fetch OIDC token
echo "Fetching GitHub Actions OIDC token..."
OIDC_RESPONSE=$(curl -s -H "Authorization: bearer ${ACTIONS_ID_TOKEN_REQUEST_TOKEN}" \
  "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=sts.amazonaws.com")
echo "${OIDC_RESPONSE}" | jq -r '.value' > "${TOKEN_FILE}"

if [[ ! -s "${TOKEN_FILE}" ]]; then
  echo "::error::Failed to fetch OIDC token"
  exit 1
fi

# Temporarily configure root account access to call Organizations API
export AWS_ROLE_ARN="arn:aws:iam::${AWS_ROOT_ACCOUNT_ID}:role/${ROLE_PATH}"
export AWS_WEB_IDENTITY_TOKEN_FILE="${TOKEN_FILE}"
export AWS_REGION="${REGION}"

echo "Listing AWS Organization accounts..."
ACCOUNTS=$(aws organizations list-accounts \
  --query 'Accounts[?Status==`ACTIVE`].[Name,Id]' \
  --output text)

if [[ -z "${ACCOUNTS}" ]]; then
  echo "::error::No accounts returned from Organizations API"
  exit 1
fi

# Clear temporary env vars so terraform uses config file profiles
unset AWS_ROLE_ARN
unset AWS_WEB_IDENTITY_TOKEN_FILE
unset AWS_REGION

# Generate ~/.aws/config
mkdir -p ~/.aws
CONFIG_FILE=~/.aws/config

echo "Generating ${CONFIG_FILE}..."
: > "${CONFIG_FILE}"

while IFS=$'\t' read -r name id; do
  # Account names from Organizations match profile names (root, prod, dev, audit, auth)
  cat >> "${CONFIG_FILE}" <<EOF
[profile ${name}]
role_arn = arn:aws:iam::${id}:role/${ROLE_PATH}
web_identity_token_file = ${TOKEN_FILE}
role_session_name = github-actions
region = ${REGION}

EOF
  echo "  Configured profile: ${name} (${id})"
done <<< "${ACCOUNTS}"

echo "AWS profiles configured successfully."
