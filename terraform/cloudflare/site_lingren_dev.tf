module "zone_lingren_dev" {
  source = "../../terraform-modules/zone//"

  domain                = "lingren.dev"
  cloudflare_account_id = cloudflare_account.account.id

  google_site_verifications = [
    "google-site-verification=JeLH9GJQwiZcrPqaWQ4ZRVa6vTgQ1gopMDL1NjwWrqY", # https://search.google.com/search-console/welcome
  ]
}

resource "cloudflare_dns_record" "lingren_dev" {
  zone_id = module.zone_lingren_dev.id
  proxied = true
  name    = "lingren.dev"
  type    = "CNAME"
  ttl     = 1
  content = "seanlingren.com" # superseded by below redirect
}

resource "cloudflare_dns_record" "star_lingren_dev" {
  zone_id = module.zone_lingren_dev.id
  proxied = true
  name    = "*.lingren.dev"
  type    = "CNAME"
  ttl     = 1
  content = "seanlingren.com" # superseded by below redirect
}

resource "cloudflare_ruleset" "redirect_lingren_dev_to_seanlingren_com" {
  zone_id = module.zone_lingren_dev.id

  name        = "redirect"
  description = "redirect [*.]lingren.dev to seanlingren.com"

  kind  = "zone"
  phase = "http_request_dynamic_redirect"

  rules = [
    {
      action      = "redirect"
      description = "redirect [*.]lingren.dev to seanlingren.com"
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
