module "zone_srlingren_com" {
  source = "../../terraform-modules/zone//"

  domain                = "srlingren.com"
  cloudflare_account_id = data.cloudflare_account.account.account_id

  google_site_verifications = [
    "google-site-verification=hQbHYjjZ9cakdTTBoYtnm7vwIoQ2O0uEEK9DCQZzez0", # https://search.google.com/search-console/welcome
  ]
}

resource "cloudflare_dns_record" "srlingren_com" {
  zone_id = module.zone_srlingren_com.id
  proxied = true
  name    = "srlingren.com"
  type    = "CNAME"
  ttl     = 1
  content = "lingrino.com" # superseded by below redirect
}

resource "cloudflare_dns_record" "star_srlingren_com" {
  zone_id = module.zone_srlingren_com.id
  proxied = true
  name    = "*.srlingren.com"
  type    = "CNAME"
  ttl     = 1
  content = "lingrino.com" # superseded by below redirect
}

resource "cloudflare_ruleset" "redirect_srlingren_com_to_seanlingren_com" {
  zone_id = module.zone_srlingren_com.id

  name        = "redirect"
  description = "redirect [*.]srlingren.com to seanlingren.com"

  kind  = "zone"
  phase = "http_request_dynamic_redirect"

  rules = [
    {
      action      = "redirect"
      description = "redirect [*.]srlingren.com to seanlingren.com"
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
