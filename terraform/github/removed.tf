#################################
### Deleted Repos             ###
#################################
# GitHub refuses to delete a repo's default branch, and Terraform destroys a
# repo's branch before the repo itself, so the apply of #3037 stopped before
# deleting podvec, stonk and scratch. Forget the branches instead: deleting each
# repo deletes its branch with it. Remove this file once that apply has run.
removed {
  from = github_branch.podvec

  lifecycle {
    destroy = false
  }
}

removed {
  from = github_branch.stonk

  lifecycle {
    destroy = false
  }
}

removed {
  from = github_branch.scratch

  lifecycle {
    destroy = false
  }
}
