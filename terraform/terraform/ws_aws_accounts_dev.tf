resource "tfe_workspace" "aws_accounts_dev" {
  organization = tfe_organization.org.id
  name         = "aws-accounts-dev"

  terraform_version = "1.14.2"
  working_directory = "terraform/aws/accounts/dev"

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
    "terraform/aws/accounts/dev/*.tf",
    "terraform-modules/**/*.tf",
  ]
}

resource "tfe_workspace_settings" "aws_accounts_dev" {
  workspace_id        = tfe_workspace.aws_accounts_dev.id
  global_remote_state = true
}

resource "tfe_workspace_variable_set" "aws_accounts_dev" {
  workspace_id    = tfe_workspace.aws_accounts_dev.id
  variable_set_id = tfe_variable_set.all.id
}

resource "tfe_notification_configuration" "aws_accounts_dev" {
  name         = "aws_accounts_dev"
  enabled      = true
  workspace_id = tfe_workspace.aws_accounts_dev.id

  destination_type = "email"
  email_user_ids   = [tfe_organization_membership.lingrino.user_id]

  triggers = [
    "run:errored",
    "run:needs_attention",
  ]
}
