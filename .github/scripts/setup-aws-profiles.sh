#!/usr/bin/env bash
set -euo pipefail

# Fetches a GitHub Actions OIDC token and generates ~/.aws/config with a
# named profile per account. Each profile assumes the github-actions OIDC role.
#
# Requires:
#   - ACTIONS_ID_TOKEN_REQUEST_URL and ACTIONS_ID_TOKEN_REQUEST_TOKEN (set by GitHub Actions when id-token: write is granted)
#   - AWS_ACCOUNT_IDS environment variable (JSON object mapping account names to IDs, e.g. {"prod":"123","dev":"456"})

if [[ -z "${AWS_ACCOUNT_IDS:-}" ]]; then
  echo "::error::AWS_ACCOUNT_IDS is not set"
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

# Generate ~/.aws/config from the account IDs map
mkdir -p ~/.aws
CONFIG_FILE=~/.aws/config

echo "Generating ${CONFIG_FILE}..."
: > "${CONFIG_FILE}"
chmod 600 "${CONFIG_FILE}"

echo "${AWS_ACCOUNT_IDS}" | jq -r 'to_entries[] | "\(.key)\t\(.value)"' | while IFS=$'\t' read -r name id; do
  cat >> "${CONFIG_FILE}" <<EOF
[profile ${name}]
role_arn = arn:aws:iam::${id}:role/${ROLE_PATH}
web_identity_token_file = ${TOKEN_FILE}
role_session_name = github-actions
region = ${REGION}

EOF
  echo "  Configured profile: ${name} (${id})"
done

echo "AWS profiles configured successfully."
