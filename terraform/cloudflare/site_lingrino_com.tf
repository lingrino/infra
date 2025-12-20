module "zone_lingrino_com" {
  source = "../../terraform-modules/zone//"

  domain                = "lingrino.com"
  cloudflare_account_id = data.cloudflare_account.account.account_id

  enable_gsuite     = true
  gsuite_dkim_value = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAiHgGtni6fQyjayMdUE73YSMSFHGr6O5DX9eP1tvVIiY637jT83srK7udP+2Zyp3P0mLz72gmKIHF06FHHk7M3oCcrbrF8VKo47EBOAhRkwx56tyVv3jwRXE56IFhR/oK7g3uIwlbscBQQNS7YZ8Frsw5kiPjwfKE6cwjfFsWfwxNOfgpHCTkyJWAlO1xz85cMKBtqcvjYVjTAPpBlIDzV3rHJQpVRiqu2m9iU092P7M1jobgf3i6Z/CP7NCq9PmIcjGxioUJKLoXwp9n/qkvmKcQCf8x/pf7BttkO0ay0nZXAD3EOB8bovYv4giZZbSBadidpIAjYNmnjAj6H8DJQQIDAQAB"
  google_site_verifications = [
    "google-site-verification=Z_0sabCX_ouSK55gpGCOfT94pJ3PS8opdHpWDfA2zY4", # https://admin.google.com
    "google-site-verification=x960BR9hmXBErt3Hu1OzopZuf-CCkeOHCphwD4ZZHIY", # https://search.google.com/search-console/welcome
  ]
}

resource "cloudflare_dns_record" "lingrino_com" {
  zone_id = module.zone_lingrino_com.id
  proxied = true
  name    = "lingrino.com"
  type    = "CNAME"
  ttl     = 1
  content = "seanlingren.com" # superseded by below redirect
}

resource "cloudflare_dns_record" "star_lingrino_com" {
  zone_id = module.zone_lingrino_com.id
  proxied = true
  name    = "*.lingrino.com"
  type    = "CNAME"
  ttl     = 1
  content = "seanlingren.com" # superseded by below redirect
}

resource "cloudflare_ruleset" "redirect_lingrino_com_to_seanlingren_com" {
  zone_id = module.zone_lingrino_com.id

  name        = "redirect"
  description = "redirect [*.]lingrino.com to seanlingren.com"

  kind  = "zone"
  phase = "http_request_dynamic_redirect"

  rules = [
    {
      action      = "redirect"
      description = "redirect [*.]lingrino.com to seanlingren.com"
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
