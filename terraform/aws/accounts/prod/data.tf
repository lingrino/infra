data "github_repositories" "lingrino" {
  query = "org:lingrino"
}

data "cloudflare_account" "account" {
  account_id = "27a6422e1d64fbe9408ab703847ecdab"
}

data "cloudflare_account_api_token_permission_groups_list" "all" {
  account_id = data.cloudflare_account.account.id
}

locals {
  account_permission_group_ids = [for k, v in data.cloudflare_account_api_token_permission_groups_list.all.result : { id = v.id } if v.scopes[0] == "com.cloudflare.api.account" && v.name != "Account API Tokens Write"]
  zone_permission_group_ids    = [for k, v in data.cloudflare_account_api_token_permission_groups_list.all.result : { id = v.id } if v.scopes[0] == "com.cloudflare.api.account.zone"]
}
