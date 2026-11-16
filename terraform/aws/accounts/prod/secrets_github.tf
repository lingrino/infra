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

resource "github_actions_secret" "fred_homebrew_tap" {
  repository  = "fred"
  secret_name = "HOMEBREW_TAP_GITHUB_TOKEN"
  value       = jsondecode(data.aws_secretsmanager_secret_version.github_keys_goreleaser.secret_string)["GORELEASER_GITHUB_TOKEN"]
}

# Apple Developer ID signing + notarization for fred's releases. The value (JSON) is set
# by fred's scripts/store-release-secrets.sh, which checks it before storing.
resource "aws_secretsmanager_secret" "github_keys_fred" {
  name = "github/keys/fred"

  tags = {
    Name = "github/keys/fred"
  }
}

data "aws_secretsmanager_secret_version" "github_keys_fred" {
  secret_id = aws_secretsmanager_secret.github_keys_fred.id
}

resource "github_actions_secret" "fred_release" {
  for_each = toset([
    "APPLE_CERT_P12_BASE64",
    "APPLE_CERT_PASSWORD",
    "APPLE_API_KEY_P8_BASE64",
    "APPLE_API_KEY_ID",
    "APPLE_API_ISSUER_ID",
  ])

  repository  = "fred"
  secret_name = each.key
  value       = jsondecode(data.aws_secretsmanager_secret_version.github_keys_fred.secret_string)[each.key]
}
