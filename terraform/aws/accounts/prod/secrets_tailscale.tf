resource "tailscale_oauth_client" "infra" {
  description = "infra"
  scopes      = ["all"]
}

ephemeral "aws_secretsmanager_secret_version" "tailscale" {
  secret_id = "tailscale/keys/infra"
}

resource "aws_secretsmanager_secret" "tailscale_keys_infra" {
  name = "tailscale/keys/infra"

  tags = {
    Name = "tailscale/keys/infra"
  }
}

resource "aws_secretsmanager_secret_version" "tailscale_keys_infra" {
  secret_id = aws_secretsmanager_secret.tailscale_keys_infra.id
  secret_string = jsonencode({
    TAILSCALE_OAUTH_CLIENT_ID     = tailscale_oauth_client.infra.id,
    TAILSCALE_OAUTH_CLIENT_SECRET = tailscale_oauth_client.infra.key,
  })
}
