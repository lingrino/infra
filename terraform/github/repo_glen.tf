resource "github_repository" "glen" {
  name         = "glen"
  description  = "cli to export gitlab variables"
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

resource "github_branch" "glen" {
  repository = github_repository.glen.name
  branch     = "main"
}

resource "github_branch_default" "glen" {
  repository = github_repository.glen.name
  branch     = github_branch.glen.branch
}

resource "github_repository_ruleset" "glen" {
  name        = "main"
  repository  = github_repository.glen.name
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
        for_each = ["golangci", "gomod", "goreleaser", "test"]

        content {
          context        = required_check.value
          integration_id = 0
        }
      }
    }
  }
}

resource "github_actions_repository_permissions" "glen" {
  repository      = github_repository.glen.name
  allowed_actions = "selected"

  allowed_actions_config {
    github_owned_allowed = true
    verified_allowed     = true
    patterns_allowed     = ["golangci/golangci-lint-action@*"]
  }
}
