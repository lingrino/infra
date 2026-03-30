resource "aws_secretsmanager_secret" "apps_agent_archiver_production" {
  name = "apps/agent-archiver/production"

  tags = {
    Name = "apps/agent-archiver/production"
  }
}

data "aws_secretsmanager_secret_version" "apps_agent_archiver_production" {
  secret_id = aws_secretsmanager_secret.apps_agent_archiver_production.id
}

resource "aws_secretsmanager_secret_version" "apps_agent_archiver_production" {
  secret_id = aws_secretsmanager_secret.apps_agent_archiver_production.id
  secret_string = jsonencode(merge({
    CLOUDFLARE_ACCOUNT_ID = data.cloudflare_account.account.id
    CLOUDFLARE_API_TOKEN  = cloudflare_account_token.agent_archiver_production.value
  }, jsondecode(data.aws_secretsmanager_secret_version.apps_agent_archiver_production.secret_string)))
}

resource "cloudflare_account_token" "agent_archiver_production" {
  provider = cloudflare.create-tokens

  name       = "agent-archiver-production"
  account_id = data.cloudflare_account.account.id

  policies = [
    {
      effect = "allow"
      resources = jsonencode({
        "com.cloudflare.api.account.${data.cloudflare_account.account.id}" = "*"
      })
      permission_groups = [
        for k, v in data.cloudflare_account_api_token_permission_groups_list.all.result :
        { id = v.id } if v.name == "Browser Rendering Write"
      ]
    }
  ]
}
