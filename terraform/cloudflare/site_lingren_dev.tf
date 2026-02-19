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

#################################
### resend                    ###
#################################
resource "cloudflare_dns_record" "txt_dmarc_lingren_dev" {
  zone_id = module.zone_lingren_dev.id
  name    = "_dmarc.lingren.dev"
  type    = "TXT"
  ttl     = 1
  content = "v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; pct=100; rua=mailto:sean+dmarc@lingren.com"
}

resource "cloudflare_dns_record" "mx_updates_lingren_dev" {
  zone_id  = module.zone_lingren_dev.id
  name     = "updates.lingren.dev"
  type     = "MX"
  ttl      = 1
  priority = 10
  content  = "inbound-smtp.us-east-1.amazonaws.com"
}

resource "cloudflare_dns_record" "mx_send_updates_lingren_dev" {
  zone_id  = module.zone_lingren_dev.id
  name     = "send.updates.lingren.dev"
  type     = "MX"
  ttl      = 1
  priority = 10
  content  = "feedback-smtp.us-east-1.amazonses.com"
}

resource "cloudflare_dns_record" "txt_send_updates_lingren_dev" {
  zone_id = module.zone_lingren_dev.id
  name    = "send.updates.lingren.dev"
  type    = "TXT"
  ttl     = 1
  content = "v=spf1 include:amazonses.com ~all"
}

resource "cloudflare_dns_record" "txt_resend_domainkey_updates_lingren_dev" {
  zone_id = module.zone_lingren_dev.id
  name    = "resend._domainkey.updates.lingren.dev"
  type    = "TXT"
  ttl     = 1
  content = "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDrySM7GcHIsXD833voXT/L2tCsVls9UyGifYPY78fpSWxGYVoA5FWAueKiheqsMngSPgExR4WuiDHdrluwA1iVKRIMGDspFqheZVYYNWH4GPAG2Sp27ibVIJU7Onz/0xmS8ecVPUvwM8JcqhFS2R8w5TEJpkmN0mujEHLgzBKltQIDAQAB"
}
