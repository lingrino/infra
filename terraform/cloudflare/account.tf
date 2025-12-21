resource "cloudflare_account" "account" {
  name = "lingrino"
  type = "standard"

  settings = {
    enforce_twofactor   = true
    abuse_contact_email = "sean@lingren.com"
  }
}
