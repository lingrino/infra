resource "github_repository" "podvec" {
  name         = "podvec"
  homepage_url = "https://seanlingren.com"

  visibility = "private"

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
}

resource "github_branch" "podvec" {
  repository = github_repository.podvec.name
  branch     = "main"
}

resource "github_branch_default" "podvec" {
  repository = github_repository.podvec.name
  branch     = github_branch.podvec.branch
}

resource "github_repository_ruleset" "podvec" {
  name        = "main"
  repository  = github_repository.podvec.name
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

resource "github_actions_repository_permissions" "podvec" {
  repository      = github_repository.podvec.name
  allowed_actions = "all"

  # todo uncomment when repo is public
  # allowed_actions_config {
  #   github_owned_allowed = true
  #   verified_allowed     = true
  #   patterns_allowed = [
  #     "extractions/setup-just@*",
  #     "federicocarboni/setup-ffmpeg@*",
  #   ]
  # }
}
