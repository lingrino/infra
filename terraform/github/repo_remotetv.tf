resource "github_repository" "remotetv" {
  name         = "remotetv"
  description  = "mac apple tv remote"
  homepage_url = "https://seanlingren.com"

  visibility = "public"

  # Secret scanning is added in a follow-up: GitHub rejects it in the same update that
  # makes a private repo public ("not available for this repository").

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
}

resource "github_branch" "remotetv" {
  repository = github_repository.remotetv.name
  branch     = "main"
}

resource "github_branch_default" "remotetv" {
  repository = github_repository.remotetv.name
  branch     = github_branch.remotetv.branch
}

resource "github_repository_ruleset" "remotetv" {
  name        = "main"
  repository  = github_repository.remotetv.name
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

resource "github_actions_repository_permissions" "remotetv" {
  repository      = github_repository.remotetv.name
  allowed_actions = "selected"

  allowed_actions_config {
    github_owned_allowed = true
    verified_allowed     = true
    patterns_allowed     = []
  }
}
