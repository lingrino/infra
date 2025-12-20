resource "tfe_workspace" "aws_common_organization" {
  organization = tfe_organization.org.id
  name         = "aws-common-organization"

  terraform_version = "1.14.2"
  working_directory = "terraform/aws/common/organization"

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
    "terraform/aws/common/organization/*.tf",
    "terraform-modules/**/*.tf",
  ]
}

resource "tfe_workspace_settings" "aws_common_organization" {
  workspace_id        = tfe_workspace.aws_common_organization.id
  global_remote_state = true
}

resource "tfe_workspace_variable_set" "aws_common_organization" {
  workspace_id    = tfe_workspace.aws_common_organization.id
  variable_set_id = tfe_variable_set.all.id
}

resource "tfe_notification_configuration" "aws_common_organization" {
  name         = "aws_common_organization"
  enabled      = true
  workspace_id = tfe_workspace.aws_common_organization.id

  destination_type = "email"
  email_user_ids   = [tfe_organization_membership.lingrino.user_id]

  triggers = [
    "run:errored",
    "run:needs_attention",
  ]
}
