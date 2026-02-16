data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]

  tags = {
    Name = "github-actions"
  }
}

resource "aws_iam_role" "github_actions" {
  name = "github-actions"
  path = "/service/"

  assume_role_policy = data.aws_iam_policy_document.arp_github_actions.json

  tags = {
    Name = "github-actions"
  }
}

resource "aws_iam_role_policy_attachments_exclusive" "github_actions_administrator" {
  role_name   = aws_iam_role.github_actions.name
  policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

data "aws_iam_policy_document" "arp_github_actions" {
  statement {
    sid = "OIDCGithubActions"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:lingrino/infra:ref:*", "repo:lingrino/infra:pull_request"]
    }
  }
}
