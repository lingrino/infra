resource "github_repository" "mini" {
  name         = "mini"
  homepage_url = "https://seanlingren.com"

  visibility = "private"

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

resource "github_branch" "mini" {
  repository = github_repository.mini.name
  branch     = "main"
}

resource "github_branch_default" "mini" {
  repository = github_repository.mini.name
  branch     = github_branch.mini.branch
}

resource "github_repository_ruleset" "mini" {
  name        = "main"
  repository  = github_repository.mini.name
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

resource "github_actions_repository_permissions" "mini" {
  repository = github_repository.mini.name
  enabled    = false
}
