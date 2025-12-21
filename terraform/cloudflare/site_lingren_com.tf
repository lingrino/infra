module "zone_lingren_com" {
  source = "../../terraform-modules/zone//"

  domain                = "lingren.com"
  cloudflare_account_id = cloudflare_account.account.id

  enable_gsuite     = true
  gsuite_dkim_value = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAgHnP3rcpXx9kS2EVNQrxx9RX6+XDzyp520TlCkJE4MY1V7x8gX3xbe+nlZqdxKy79QbP3ZOf98+J5tw0wjGJIVucpBLr1nqN/N7hfyn5hSx+K4dQ2YjpS0LBvkWhRiegGeJas5UUba4Hlk0ZFfmcotjapKmSYtt1ZMfjareHo6nvCrPSrhbe19CVqgifXSi2JGFVj2sHweZWWEgsKpqSl6//XkYAm0kFseeGtWvKQGN5n03aYwHZQqg8x2evVmRTMfPYlE7cZxvjf0QItykAj6LCpB7l52WoBszJGGJ1E3NFWByXih4M2a0RFLZAkEVKGEcIwja5nrs6rkZNGQiDDQIDAQAB"

  google_site_verifications = [
    "google-site-verification=a0-Z4NWqKxxOU7qkFlNCsg1V_GgZFIzODQSkSI4jL7o", # https://admin.google.com
    "google-site-verification=_AknlqaZqFV-iSpS7EkWHIcT_zmqN23Sr4WTX5KZLew", # https://search.google.com/search-console/welcome
  ]
}

resource "cloudflare_dns_record" "lingren_com" {
  zone_id = module.zone_lingren_com.id
  proxied = true
  name    = "lingren.com"
  type    = "CNAME"
  ttl     = 1
  content = "seanlingren.com" # superseded by below redirect
}

resource "cloudflare_dns_record" "star_lingren_com" {
  zone_id = module.zone_lingren_com.id
  proxied = true
  name    = "*.lingren.com"
  type    = "CNAME"
  ttl     = 1
  content = "seanlingren.com" # superseded by below redirect
}

resource "cloudflare_dns_record" "atproto_lingren_com" {
  zone_id = module.zone_lingren_com.id
  name    = "_atproto.lingren.com"
  type    = "TXT"
  ttl     = 1
  content = "\"did=did:plc:k6ylnfky52hxfl7yoxfnbwot\""
}

resource "cloudflare_ruleset" "redirect_lingren_com_to_seanlingren_com" {
  zone_id = module.zone_lingren_com.id

  name        = "redirect"
  description = "redirect [*.]lingren.com to seanlingren.com"

  kind  = "zone"
  phase = "http_request_dynamic_redirect"

  rules = [
    {
      action      = "redirect"
      description = "redirect [*.]lingren.com to seanlingren.com"
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
