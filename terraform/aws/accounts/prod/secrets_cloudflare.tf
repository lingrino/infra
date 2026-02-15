#################################
### Create Tokens             ###
#################################
resource "aws_secretsmanager_secret" "cloudflare_keys_create_tokens" {
  name = "cloudflare/keys/create-tokens"

  tags = {
    Name = "cloudflare/keys/create-tokens"
  }
}

ephemeral "aws_secretsmanager_secret_version" "cloudflare_keys_create_tokens" {
  secret_id = aws_secretsmanager_secret.cloudflare_keys_create_tokens.id
}

#################################
### Infra                     ###
#################################
resource "aws_secretsmanager_secret" "cloudflare_keys_infra" {
  name = "cloudflare/keys/infra"

  tags = {
    Name = "cloudflare/keys/infra"
  }
}

ephemeral "aws_secretsmanager_secret_version" "cloudflare_keys_infra" {
  secret_id = aws_secretsmanager_secret.cloudflare_keys_infra.id
}

resource "aws_secretsmanager_secret_version" "cloudflare_keys_infra" {
  secret_id = aws_secretsmanager_secret.cloudflare_keys_infra.id
  secret_string = jsonencode({
    CLOUDFLARE_API_TOKEN = cloudflare_account_token.infra.value,
  })
}

resource "cloudflare_account_token" "infra" {
  provider = cloudflare.create-tokens

  name       = "infra"
  account_id = data.cloudflare_account.account.id

  policies = [
    {
      effect = "allow"
      resources = jsonencode({
        "com.cloudflare.api.account.${data.cloudflare_account.account.id}" = "*"
      })
      permission_groups = local.account_permission_group_ids
    },
    {
      effect = "allow"
      resources = jsonencode({
        "com.cloudflare.api.account.${data.cloudflare_account.account.id}" = "*"
      })
      permission_groups = local.zone_permission_group_ids
    }
  ]
}

#################################
### Local                     ###
#################################
resource "aws_secretsmanager_secret" "cloudflare_keys_local" {
  name = "cloudflare/keys/local"

  tags = {
    Name = "cloudflare/keys/local"
  }
}

resource "aws_secretsmanager_secret_version" "cloudflare_keys_local" {
  secret_id = aws_secretsmanager_secret.cloudflare_keys_local.id
  secret_string = jsonencode({
    CLOUDFLARE_API_TOKEN = cloudflare_account_token.local.value,
  })
}

resource "cloudflare_account_token" "local" {
  provider = cloudflare.create-tokens

  name       = "local"
  account_id = data.cloudflare_account.account.id

  policies = [
    {
      effect = "allow"
      resources = jsonencode({
        "com.cloudflare.api.account.${data.cloudflare_account.account.id}" = "*"
      })
      permission_groups = local.account_permission_group_ids
    },
    {
      effect = "allow"
      resources = jsonencode({
        "com.cloudflare.api.account.${data.cloudflare_account.account.id}" = "*"
      })
      permission_groups = local.zone_permission_group_ids
    }
  ]
}
