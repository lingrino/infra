module "zone_lingren_org" {
  source = "../../terraform-modules/zone//"

  domain                = "lingren.org"
  cloudflare_account_id = data.cloudflare_account.account.account_id

  google_site_verifications = [
    "google-site-verification=2wlyDNZ9mK6gUXJAYzqixYSIv84J-2bVFWmzNotzshI", # https://search.google.com/search-console/welcome
  ]
}

resource "cloudflare_dns_record" "lingren_org" {
  zone_id = module.zone_lingren_org.id
  proxied = true
  name    = "lingren.org"
  type    = "CNAME"
  ttl     = 1
  content = "seanlingren.com" # superseded by below redirect
}

resource "cloudflare_dns_record" "star_lingren_org" {
  zone_id = module.zone_lingren_org.id
  proxied = true
  name    = "*.lingren.org"
  type    = "CNAME"
  ttl     = 1
  content = "seanlingren.com" # superseded by below redirect
}

resource "cloudflare_ruleset" "redirect_lingren_org_to_seanlingren_com" {
  zone_id = module.zone_lingren_org.id

  name        = "redirect"
  description = "redirect [*.]lingren.org to seanlingren.com"

  kind  = "zone"
  phase = "http_request_dynamic_redirect"

  rules = [
    {
      action      = "redirect"
      description = "redirect [*.]lingren.org to seanlingren.com"
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
