data "github_repositories" "lingrino" {
  query = "org:lingrino"
}

data "cloudflare_api_token_permission_groups_list" "all" {
  provider = cloudflare.create-tokens
}

locals {
  account_permission_group_ids = [for k, v in data.cloudflare_api_token_permission_groups_list.all.result : { id = v.id } if v.scopes[0] == "com.cloudflare.api.account" && v.name != "Account API Tokens Write"]
  zone_permission_group_ids    = [for k, v in data.cloudflare_api_token_permission_groups_list.all.result : { id = v.id } if v.scopes[0] == "com.cloudflare.api.account.zone"]
}
