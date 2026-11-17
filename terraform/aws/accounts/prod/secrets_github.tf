#################################
### Terraform Cloud           ###
#################################
resource "aws_secretsmanager_secret" "github_keys_infra" {
  name = "github/keys/infra"

  tags = {
    Name = "github/keys/infra"
  }
}

ephemeral "aws_secretsmanager_secret_version" "github_keys_infra" {
  secret_id = aws_secretsmanager_secret.github_keys_infra.id
}

#################################
### GitHub                    ###
#################################
resource "aws_secretsmanager_secret" "github_keys_goreleaser" {
  name = "github/keys/goreleaser"

  tags = {
    Name = "github/keys/goreleaser"
  }
}

data "aws_secretsmanager_secret_version" "github_keys_goreleaser" {
  secret_id = aws_secretsmanager_secret.github_keys_goreleaser.id
}

resource "github_actions_secret" "agent_archiver_goreleaser" {
  repository  = "agent-archiver"
  secret_name = "GORELEASER_GITHUB_TOKEN"
  value       = jsondecode(data.aws_secretsmanager_secret_version.github_keys_goreleaser.secret_string)["GORELEASER_GITHUB_TOKEN"]
}

resource "github_actions_secret" "vaku_goreleaser" {
  repository  = "vaku"
  secret_name = "GORELEASER_GITHUB_TOKEN"
  value       = jsondecode(data.aws_secretsmanager_secret_version.github_keys_goreleaser.secret_string)["GORELEASER_GITHUB_TOKEN"]
}

resource "github_actions_secret" "glen_goreleaser" {
  repository  = "glen"
  secret_name = "GORELEASER_GITHUB_TOKEN"
  value       = jsondecode(data.aws_secretsmanager_secret_version.github_keys_goreleaser.secret_string)["GORELEASER_GITHUB_TOKEN"]
}

#################################
### Mac apps                  ###
#################################
# Mac apps released as signed, notarized casks in lingrino/homebrew-tap (fred's release
# workflow is the template). Each one gets the Developer ID + notarization secrets and
# the tap token: add a repo here when it starts releasing.
locals {
  mac_app_repos = ["fred"]

  apple_developer_secret_names = [
    "APPLE_CERT_P12_BASE64",
    "APPLE_CERT_PASSWORD",
    "APPLE_API_KEY_P8_BASE64",
    "APPLE_API_KEY_ID",
    "APPLE_API_ISSUER_ID",
  ]
}

# The team's Developer ID Application certificate and App Store Connect API key (JSON),
# shared by every Mac app. Set by fred's scripts/store-release-secrets.sh, which checks it
# before storing; repos get a new value on the next apply.
resource "aws_secretsmanager_secret" "github_keys_apple_developer" {
  name = "github/keys/apple-developer"

  tags = {
    Name = "github/keys/apple-developer"
  }
}

# Reads AWSCURRENT; going through the one-time copy only orders the first read after it.
data "aws_secretsmanager_secret_version" "github_keys_apple_developer" {
  secret_id = aws_secretsmanager_secret_version.github_keys_apple_developer_from_fred.secret_id
}

resource "github_actions_secret" "mac_app_apple_developer" {
  for_each = {
    for pair in setproduct(local.mac_app_repos, local.apple_developer_secret_names) :
    "${pair[0]}/${pair[1]}" => { repository = pair[0], secret_name = pair[1] }
  }

  repository  = each.value.repository
  secret_name = each.value.secret_name
  value       = jsondecode(data.aws_secretsmanager_secret_version.github_keys_apple_developer.secret_string)[each.value.secret_name]
}

resource "github_actions_secret" "mac_app_homebrew_tap" {
  for_each = toset(local.mac_app_repos)

  repository  = each.value
  secret_name = "HOMEBREW_TAP_GITHUB_TOKEN"
  value       = jsondecode(data.aws_secretsmanager_secret_version.github_keys_goreleaser.secret_string)["GORELEASER_GITHUB_TOKEN"]
}

moved {
  from = github_actions_secret.fred_homebrew_tap
  to   = github_actions_secret.mac_app_homebrew_tap["fred"]
}

moved {
  from = github_actions_secret.fred_release["APPLE_CERT_P12_BASE64"]
  to   = github_actions_secret.mac_app_apple_developer["fred/APPLE_CERT_P12_BASE64"]
}

moved {
  from = github_actions_secret.fred_release["APPLE_CERT_PASSWORD"]
  to   = github_actions_secret.mac_app_apple_developer["fred/APPLE_CERT_PASSWORD"]
}

moved {
  from = github_actions_secret.fred_release["APPLE_API_KEY_P8_BASE64"]
  to   = github_actions_secret.mac_app_apple_developer["fred/APPLE_API_KEY_P8_BASE64"]
}

moved {
  from = github_actions_secret.fred_release["APPLE_API_KEY_ID"]
  to   = github_actions_secret.mac_app_apple_developer["fred/APPLE_API_KEY_ID"]
}

moved {
  from = github_actions_secret.fred_release["APPLE_API_ISSUER_ID"]
  to   = github_actions_secret.mac_app_apple_developer["fred/APPLE_API_ISSUER_ID"]
}

# The old fred-only secret. Its value is copied once into github/keys/apple-developer
# through a write-only argument (the copy adds nothing to state; the data source above
# holds the value, as the old one did). A follow-up removes both right after this applies,
# before anything writes a newer version.
resource "aws_secretsmanager_secret" "github_keys_fred" {
  name = "github/keys/fred"

  tags = {
    Name = "github/keys/fred"
  }
}

ephemeral "aws_secretsmanager_secret_version" "github_keys_fred" {
  secret_id = aws_secretsmanager_secret.github_keys_fred.id
}

resource "aws_secretsmanager_secret_version" "github_keys_apple_developer_from_fred" {
  secret_id                = aws_secretsmanager_secret.github_keys_apple_developer.id
  secret_string_wo         = ephemeral.aws_secretsmanager_secret_version.github_keys_fred.secret_string
  secret_string_wo_version = 1
}
