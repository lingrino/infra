# todo - resource does not currently support terraform import
# https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/registrar_domain

# locals {
#   domains = toset([
#     "lingren.com",
#     "lingren.dev",
#     "lingren.org",
#     "lingrino.com",
#     "lingrino.dev",
#     "podvec.com",
#     "seanandstuggo.com",
#     "seanlingren.com",
#     "srlingren.com",
#     "uptime.how",
#     "vaku.dev",
#   ])
# }

# resource "cloudflare_registrar_domain" "domain" {
#   for_each = local.domains

#   account_id  = cloudflare_account.account.id
#   domain_name = each.value

#   locked     = true
#   privacy    = true
#   auto_renew = true
# }
