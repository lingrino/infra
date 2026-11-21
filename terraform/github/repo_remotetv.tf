resource "github_repository" "remotetv" {
  name         = "remotetv"
  description  = "mac apple tv remote"
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

resource "github_actions_repository_permissions" "remotetv" {
  repository      = github_repository.remotetv.name
  allowed_actions = "all"

  # todo uncomment when repo is public
  # allowed_actions_config {
  #   github_owned_allowed = true
  #   verified_allowed     = true
  #   patterns_allowed     = []
  # }
}
