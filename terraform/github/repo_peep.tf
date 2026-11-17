resource "github_repository" "peep" {
  name         = "peep"
  description  = "mac quick look previews for code and markdown"
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
  }
}

resource "github_actions_repository_permissions" "peep" {
  repository = github_repository.peep.name
  enabled    = false
}
