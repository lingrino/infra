resource "tailscale_tailnet_settings" "tailnet" {
  acls_externally_managed_on = true
  acls_external_link         = "https://github.com/lingrino/infra/blob/main/terraform/tailscale/acl.tf"

  devices_approval_on       = false
  devices_auto_updates_on   = true
  devices_key_duration_days = 180

  https_enabled                  = true
  posture_identity_collection_on = true

  users_approval_on                           = false
  users_role_allowed_to_join_external_tailnet = "admin"
}

resource "tailscale_contacts" "contacts" {
  account {
    email = "sean@lingren.com"
  }

  security {
    email = "sean@lingren.com"
  }

  support {
    email = "sean@lingren.com"
  }
}
