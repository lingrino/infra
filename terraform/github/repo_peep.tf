resource "github_repository" "peep" {
  name         = "peep"
  description  = "mac quick look previews for code and markdown"
  homepage_url = "https://seanlingren.com"

  visibility = "public"

  has_wiki        = false
  has_issues      = false
  has_projects    = false
  has_discussions = false

  # no dependencies: the manifests in examples/ are preview samples
  vulnerability_alerts = false

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

resource "github_branch" "peep" {
  repository = github_repository.peep.name
  branch     = "main"
}

resource "github_branch_default" "peep" {
  repository = github_repository.peep.name
  branch     = github_branch.peep.branch
}

resource "github_repository_ruleset" "peep" {
  name        = "main"
  repository  = github_repository.peep.name
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
        for_each = ["check", "package", "scripts"]

        content {
          context        = required_check.value
          integration_id = 15368
        }
      }
    }
  }
}

resource "github_actions_repository_permissions" "peep" {
  repository      = github_repository.peep.name
  allowed_actions = "selected"

  allowed_actions_config {
    github_owned_allowed = true
    verified_allowed     = true
    patterns_allowed     = []
  }
}
