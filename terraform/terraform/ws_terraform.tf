resource "tfe_workspace" "terraform" {
  organization = tfe_organization.org.id
  name         = "terraform"

  terraform_version = "1.14.2"
  working_directory = "terraform/terraform"

  auto_apply            = true
  queue_all_runs        = false
  allow_destroy_plan    = false
  file_triggers_enabled = true

  vcs_repo {
    identifier     = "lingrino/infra-personal"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  trigger_patterns = [
    "terraform/terraform/*.tf",
    "terraform-modules/**/*.tf",
  ]
}

resource "tfe_workspace_settings" "terraform" {
  workspace_id        = tfe_workspace.terraform.id
  global_remote_state = true
}

resource "tfe_workspace_variable_set" "terraform" {
  workspace_id    = tfe_workspace.terraform.id
  variable_set_id = tfe_variable_set.all.id
}

resource "tfe_notification_configuration" "terraform" {
  name         = "terraform"
  enabled      = true
  workspace_id = tfe_workspace.terraform.id

  destination_type = "email"
  email_user_ids   = [tfe_organization_membership.lingrino.user_id]

  triggers = [
    "run:errored",
    "run:needs_attention",
  ]
}
