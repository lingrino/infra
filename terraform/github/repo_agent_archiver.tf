resource "github_repository" "agent_archiver" {
  name         = "agent-archiver"
  description  = "export sites to markdown"
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

resource "github_branch" "agent_archiver" {
  repository = github_repository.agent_archiver.name
  branch     = "main"
}

resource "github_branch_default" "agent_archiver" {
  repository = github_repository.agent_archiver.name
  branch     = github_branch.agent_archiver.branch
}

resource "github_repository_ruleset" "agent_archiver" {
  name        = "main"
  repository  = github_repository.agent_archiver.name
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
        for_each = ["docs", "golangci", "gomod", "goreleaser", "test"]

        content {
          context        = required_check.value
          integration_id = 0
        }
      }
    }
  }
}

resource "github_actions_repository_permissions" "agent_archiver" {
  repository      = github_repository.agent_archiver.name
  allowed_actions = "selected"

  allowed_actions_config {
    github_owned_allowed = true
    verified_allowed     = true
    patterns_allowed     = ["golangci/golangci-lint-action@*"]
  }
}
