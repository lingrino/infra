resource "github_repository" "dotgithub" {
  name         = ".github"
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

resource "github_branch" "dotgithub" {
  repository = github_repository.dotgithub.name
  branch     = "main"
}

resource "github_branch_default" "dotgithub" {
  repository = github_repository.dotgithub.name
  branch     = github_branch.dotgithub.branch
}

resource "github_repository_ruleset" "dotgithub" {
  name        = "main"
  repository  = github_repository.dotgithub.name
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
  }
}

resource "github_actions_repository_permissions" "dotgithub" {
  repository = github_repository.dotgithub.name
  enabled    = false
}
