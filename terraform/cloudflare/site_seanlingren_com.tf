module "zone_seanlingren_com" {
  source = "../../terraform-modules/zone//"

  domain                = "seanlingren.com"
  cloudflare_account_id = cloudflare_account.account.id

  google_site_verifications = [
    "google-site-verification=cAtcJ0TFUenT4kLGmWnXh_4upiQTPYBnAYik_g_xtMU", # https://search.google.com/search-console/welcome
  ]
}

resource "cloudflare_pages_domain" "site" {
  account_id   = cloudflare_account.account.id
  project_name = cloudflare_pages_project.site.name
  name         = "seanlingren.com"
}

resource "cloudflare_pages_project" "site" {
  account_id        = cloudflare_account.account.id
  name              = "site"
  production_branch = "main"

  build_config = {
    build_command   = "go run build.go"
    destination_dir = "public"
    build_caching   = true
  }

  deployment_configs = {
    preview = {
      compatibility_date = "2025-12-20"
    }
    production = {
      compatibility_date = "2025-12-20"
    }
  }

  lifecycle {
    ignore_changes = [source]
  }
}
