resource "github_repository" "content_archive" {
  name = "content-archive"

  visibility = "private"

  has_wiki             = false
  has_issues           = false
  has_projects         = false
  has_discussions      = false
  vulnerability_alerts = false

  allow_auto_merge       = true
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = false
  allow_update_branch    = true
  delete_branch_on_merge = true
}

resource "github_branch" "content_archive" {
  repository = github_repository.content_archive.name
  branch     = "main"
}

resource "github_branch_default" "content_archive" {
  repository = github_repository.content_archive.name
  branch     = github_branch.content_archive.branch
}

resource "github_repository_ruleset" "content_archive" {
  name        = "main"
  repository  = github_repository.content_archive.name
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

resource "github_actions_repository_permissions" "content_archive" {
  repository      = github_repository.content_archive.name
  allowed_actions = "all"
}
