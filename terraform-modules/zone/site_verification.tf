resource "cloudflare_dns_record" "txt_base" {
  for_each = var.google_site_verifications

  zone_id = cloudflare_zone.zone.id
  name    = var.domain
  type    = "TXT"
  ttl     = 1
  content = "\"${each.key}\""
}
