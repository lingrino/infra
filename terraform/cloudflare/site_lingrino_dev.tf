module "zone_lingrino_dev" {
  source = "../../terraform-modules/zone//"

  domain                = "lingrino.dev"
  cloudflare_account_id = cloudflare_account.account.id

  google_site_verifications = [
    "google-site-verification=vxDuPgFxbbnn0WDnOzSZVz2zzv_rZr6EUegsu2gF6KY", # https://search.google.com/search-console/welcome
  ]
}

resource "cloudflare_dns_record" "lingrino_dev" {
  zone_id = module.zone_lingrino_dev.id
  proxied = true
  name    = "lingrino.dev"
  type    = "CNAME"
  ttl     = 1
  content = "seanlingren.com" # superseded by below redirect
}

resource "cloudflare_dns_record" "star_lingrino_dev" {
  zone_id = module.zone_lingrino_dev.id
  proxied = true
  name    = "*.lingrino.dev"
  type    = "CNAME"
  ttl     = 1
  content = "seanlingren.com" # superseded by below redirect
}

resource "cloudflare_ruleset" "redirect_lingrino_dev_to_seanlingren_com" {
  zone_id = module.zone_lingrino_dev.id

  name        = "redirect"
  description = "redirect [*.]lingrino.dev to seanlingren.com"

  kind  = "zone"
  phase = "http_request_dynamic_redirect"

  rules = [
    {
      action      = "redirect"
      description = "redirect [*.]lingrino.dev to seanlingren.com"
      expression  = "true"

      action_parameters = {
        from_value = {
          status_code = 301
          target_url = {
            value = "https://seanlingren.com"
          }
        }
      }
    }
  ]
}
