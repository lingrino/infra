resource "tfe_workspace" "tailscale" {
  organization = tfe_organization.org.id
  name         = "tailscale"

  terraform_version = "1.14.3"
  working_directory = "terraform/tailscale"

  auto_apply            = true
  queue_all_runs        = false
  allow_destroy_plan    = false
  file_triggers_enabled = true

  vcs_repo {
    identifier     = "lingrino/infra"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  trigger_patterns = [
    "terraform/tailscale/*.tf",
    "terraform-modules/**/*.tf",
  ]
}

resource "tfe_workspace_settings" "tailscale" {
  workspace_id        = tfe_workspace.tailscale.id
  global_remote_state = true
}

resource "tfe_workspace_variable_set" "tailscale" {
  workspace_id    = tfe_workspace.tailscale.id
  variable_set_id = tfe_variable_set.all.id
}

resource "tfe_notification_configuration" "tailscale" {
  name         = "tailscale"
  enabled      = true
  workspace_id = tfe_workspace.tailscale.id

  destination_type = "email"
  email_user_ids   = [tfe_organization_membership.lingrino.user_id]

  triggers = [
    "run:errored",
    "run:needs_attention",
  ]
}
