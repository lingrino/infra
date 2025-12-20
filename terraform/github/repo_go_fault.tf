resource "github_repository" "go_fault" {
  name         = "go-fault"
  description  = "go fault injection library"
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

resource "github_branch" "go_fault" {
  repository = github_repository.go_fault.name
  branch     = "main"
}

resource "github_branch_default" "go_fault" {
  repository = github_repository.go_fault.name
  branch     = github_branch.go_fault.branch
}

resource "github_repository_ruleset" "go_fault" {
  name        = "main"
  repository  = github_repository.go_fault.name
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
        for_each = ["validate (ubuntu-latest, stable)"]

        content {
          context        = required_check.value
          integration_id = 0
        }
      }
    }
  }
}

resource "github_actions_repository_permissions" "go_fault" {
  repository      = github_repository.go_fault.name
  allowed_actions = "selected"

  allowed_actions_config {
    github_owned_allowed = true
    verified_allowed     = true
    patterns_allowed     = ["golangci/golangci-lint-action@*"]
  }
}
