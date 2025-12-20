resource "github_repository" "site" {
  name         = "site"
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

resource "github_branch" "site" {
  repository = github_repository.site.name
  branch     = "main"
}

resource "github_branch_default" "site" {
  repository = github_repository.site.name
  branch     = github_branch.site.branch
}

resource "github_repository_ruleset" "site" {
  name        = "main"
  repository  = github_repository.site.name
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

resource "github_actions_repository_permissions" "site" {
  repository      = github_repository.site.name
  allowed_actions = "all"
}
