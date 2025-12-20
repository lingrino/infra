resource "github_repository" "homebrew_tap" {
  name         = "homebrew-tap"
  homepage_url = "https://seanlingren.com"

  visibility = "public"

  has_wiki             = false
  has_issues           = false
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

resource "github_branch" "homebrew_tap" {
  repository = github_repository.homebrew_tap.name
  branch     = "main"
}

resource "github_branch_default" "homebrew_tap" {
  repository = github_repository.homebrew_tap.name
  branch     = github_branch.homebrew_tap.branch
}

resource "github_repository_ruleset" "homebrew_tap" {
  name        = "main"
  repository  = github_repository.homebrew_tap.name
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
  }
}

resource "github_actions_repository_permissions" "homebrew_tap" {
  repository = github_repository.homebrew_tap.name
  enabled    = false
}
