resource "github_repository" "fred" {
  name         = "fred"
  description  = "personal macOS launcher and clipboard manager"
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

resource "github_branch" "fred" {
  repository = github_repository.fred.name
  branch     = "main"
}

resource "github_branch_default" "fred" {
  repository = github_repository.fred.name
  branch     = github_branch.fred.branch
}

resource "github_repository_ruleset" "fred" {
  name        = "main"
  repository  = github_repository.fred.name
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

resource "github_actions_repository_permissions" "fred" {
  repository = github_repository.fred.name
  enabled    = false
}
