module "zone_vaku_dev" {
  source = "../../terraform-modules/zone//"

  domain                = "vaku.dev"
  cloudflare_account_id = data.cloudflare_account.account.account_id

  google_site_verifications = [
    "google-site-verification=t2eRiObvW8NcHD8u8Wy7Ak2gG9KSihSXQUgLjFr8FEg", # https://search.google.com/search-console
  ]
}

resource "cloudflare_dns_record" "vaku_dev" {
  zone_id = module.zone_vaku_dev.id
  proxied = true
  name    = "vaku.dev"
  type    = "CNAME"
  ttl     = 1
  content = "vaku.pages.dev"
}

resource "cloudflare_pages_domain" "vaku" {
  account_id   = data.cloudflare_account.account.account_id
  project_name = cloudflare_pages_project.vaku.name
  name         = "vaku.dev"
}

resource "cloudflare_pages_project" "vaku" {
  account_id        = data.cloudflare_account.account.account_id
  name              = "vaku"
  production_branch = "main"

  build_config = {
    destination_dir = "www"
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
