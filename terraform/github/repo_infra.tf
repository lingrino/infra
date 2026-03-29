resource "github_repository" "infra" {
  name         = "infra"
  homepage_url = "https://seanlingren.com"

  visibility = "public"

  has_wiki             = false
  has_issues           = true
  has_projects         = false
  has_discussions      = false
  vulnerability_alerts = true

  allow_auto_merge       = true
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = false
  allow_update_branch    = true
  delete_branch_on_merge = true

  security_and_analysis {
    secret_scanning {
      status = "enabled"
    }
    secret_scanning_push_protection {
      status = "enabled"
    }
  }
}

resource "github_branch" "infra" {
  repository = github_repository.infra.name
  branch     = "main"
}

resource "github_branch_default" "infra" {
  repository = github_repository.infra.name
  branch     = github_branch.infra.branch
}

resource "github_repository_ruleset" "infra" {
  name        = "main"
  repository  = github_repository.infra.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    deletion = true

    required_linear_history = true
    non_fast_forward        = true

    pull_request {}

    required_status_checks {
      strict_required_status_checks_policy = true

      dynamic "required_check" {
        for_each = ["validate", "status"]

        content {
          context        = required_check.value
          integration_id = 15368 # github actions
        }
      }
    }
  }
}

resource "github_actions_secret" "infra_aws_account_ids" {
  repository      = github_repository.infra.name
  secret_name     = "AWS_ACCOUNT_IDS"
  plaintext_value = jsonencode(data.terraform_remote_state.organization.outputs.account_names_to_account_ids)
}

resource "github_actions_repository_permissions" "infra" {
  repository      = github_repository.infra.name
  allowed_actions = "selected"

  allowed_actions_config {
    github_owned_allowed = true
    verified_allowed     = true
    patterns_allowed     = ["terraform-linters/setup-tflint@*"]
  }
}
