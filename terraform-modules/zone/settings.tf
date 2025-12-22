resource "cloudflare_leaked_credential_check" "cc" {
  zone_id = cloudflare_zone.zone.id
  enabled = true
}

resource "cloudflare_schema_validation_settings" "schema" {
  zone_id = cloudflare_zone.zone.id

  validation_default_mitigation_action  = "none"
  validation_override_mitigation_action = "none"
}

resource "cloudflare_bot_management" "bot" {
  zone_id = cloudflare_zone.zone.id

  # cf_robots_variant     = "off" # todo broken in provider
  ai_bots_protection    = "disabled"
  crawler_protection    = "disabled"
  enable_js             = false
  fight_mode            = false
  is_robots_txt_managed = false
}

# all zone settings
# https://developers.cloudflare.com/api/resources/zones/subresources/settings/methods/get/

locals {
  zone_settings = {
    "0rtt"                     = "on"
    "always_online"            = "off"
    "always_use_https"         = "on"
    "automatic_https_rewrites" = "on"
    "brotli"                   = "on"
    "browser_cache_ttl"        = 1200
    "browser_check"            = "on"
    "cache_level"              = "basic"
    "challenge_ttl"            = 1800
    "development_mode"         = "off"
    "early_hints"              = "on"
    "ech"                      = "on"
    "edge_cache_ttl"           = 7200
    "email_obfuscation"        = "off"
    "hotlink_protection"       = "off"
    "http3"                    = "on"
    "ip_geolocation"           = "on"
    "ipv6"                     = "on"
    "max_upload"               = 100
    "min_tls_version"          = "1.2"
    "opportunistic_encryption" = "on"
    "opportunistic_onion"      = "on"
    "replace_insecure_js"      = "on"
    "rocket_loader"            = "off"
    "security_header" = {
      "strict_transport_security" = {
        "enabled"            = true
        "max_age"            = 31536000
        "include_subdomains" = true
        "preload"            = true
        "nosniff"            = false
      }
    }
    "server_side_exclude" = "on"
    "ssl"                 = "strict"
    "tls_1_3"             = "zrt"
    "websockets"          = "on"
  }
}

resource "cloudflare_zone_setting" "setting" {
  for_each = local.zone_settings

  zone_id    = cloudflare_zone.zone.id
  setting_id = each.key
  value      = each.value
}
