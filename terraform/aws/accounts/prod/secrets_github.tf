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
