module "zone_uptime_how" {
  source = "../../terraform-modules/zone//"

  domain                = "uptime.how"
  cloudflare_account_id = data.cloudflare_account.account.account_id

  google_site_verifications = [
    "google-site-verification=5RIxGFnjg_F2p4U4JHHdWYvt1JtynJF0xI2Iyzt_nQA", # https://search.google.com/search-console/welcome
  ]
}

resource "cloudflare_dns_record" "uptime_how" {
  zone_id = module.zone_uptime_how.id
  proxied = true
  name    = "uptime.how"
  type    = "CNAME"
  ttl     = 1
  content = "uptime-pcd3.pages.dev"
}

resource "cloudflare_pages_domain" "uptime" {
  account_id   = data.cloudflare_account.account.account_id
  project_name = cloudflare_pages_project.uptime.name
  name         = "uptime.how"
}

resource "cloudflare_pages_project" "uptime" {
  account_id        = data.cloudflare_account.account.account_id
  name              = "uptime"
  production_branch = "main"

  build_config = {
    build_command   = "npm run build"
    destination_dir = ".svelte-kit/cloudflare"
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
