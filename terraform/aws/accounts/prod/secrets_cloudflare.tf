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
### Terraform Cloud           ###
#################################
resource "aws_secretsmanager_secret" "cloudflare_keys_terraform_cloud" {
  name = "cloudflare/keys/terraform-cloud"

  tags = {
    Name = "cloudflare/keys/terraform-cloud"
  }
}

ephemeral "aws_secretsmanager_secret_version" "cloudflare_keys_terraform_cloud" {
  secret_id = aws_secretsmanager_secret.cloudflare_keys_terraform_cloud.id
}

resource "aws_secretsmanager_secret_version" "cloudflare_keys_terraform_cloud" {
  secret_id = aws_secretsmanager_secret.cloudflare_keys_terraform_cloud.id
  secret_string = jsonencode({
    CLOUDFLARE_API_TOKEN = cloudflare_account_token.terraform_cloud.value,
  })
}

resource "cloudflare_account_token" "terraform_cloud" {
  provider = cloudflare.create-tokens

  name       = "terraform-cloud"
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
