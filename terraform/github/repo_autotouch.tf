resource "github_repository" "autotouch" {
  name         = "autotouch"
  description  = "mac custom trackpad actions"
  homepage_url = "https://seanlingren.com"

  visibility = "public"

  has_wiki        = false
  has_issues      = false
  has_projects    = false
  has_discussions = false

  allow_auto_merge       = true
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = false
  allow_update_branch    = true
  delete_branch_on_merge = true

  # Secret scanning is added in a follow-up: GitHub rejects it in the same update that
  # makes a private repo public ("not available for this repository").
}

resource "github_branch" "autotouch" {
  repository = github_repository.autotouch.name
  branch     = "main"
}

resource "github_branch_default" "autotouch" {
  repository = github_repository.autotouch.name
  branch     = github_branch.autotouch.branch
}

resource "github_repository_ruleset" "autotouch" {
  name        = "main"
  repository  = github_repository.autotouch.name
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
        for_each = ["lint", "test", "scripts"]

        content {
          context        = required_check.value
          integration_id = 15368
        }
      }
    }
  }
}

resource "github_actions_repository_permissions" "autotouch" {
  repository      = github_repository.autotouch.name
  allowed_actions = "selected"

  allowed_actions_config {
    github_owned_allowed = true
    verified_allowed     = true
    patterns_allowed     = []
  }
}
