resource "aws_secretsmanager_secret" "anthropic_keys_github_actions" {
  name = "anthropic/keys/github-actions"

  tags = {
    Name = "anthropic/keys/github-actions"
  }
}
