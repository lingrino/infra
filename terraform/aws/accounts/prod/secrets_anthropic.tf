resource "aws_secretsmanager_secret" "anthropic_keys_github_actions" {
  name = "anthropic/keys/github-actions"

  tags = {
    Name = "anthropic/keys/github-actions"
  }
}

data "aws_secretsmanager_secret_version" "anthropic_keys_github_actions" {
  secret_id = aws_secretsmanager_secret.anthropic_keys_github_actions.id
}

resource "github_actions_secret" "anthropic_github_actions" {
  for_each = toset(data.github_repositories.lingrino.names)

  repository      = each.value
  secret_name     = "ANTHROPIC_API_KEY"
  plaintext_value = jsondecode(data.aws_secretsmanager_secret_version.anthropic_keys_github_actions.secret_string)["ANTHROPIC_API_KEY"]
}
