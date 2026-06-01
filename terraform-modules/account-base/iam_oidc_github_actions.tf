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

resource "aws_iam_role" "github_actions_admin" {
  name = "github-actions-admin"
  path = "/service/"

  assume_role_policy = data.aws_iam_policy_document.arp_github_actions.json

  tags = {
    Name = "github-actions-admin"
  }
}

resource "aws_iam_role" "github_actions_read" {
  name = "github-actions-read"
  path = "/service/"

  assume_role_policy = data.aws_iam_policy_document.arp_github_actions_read.json

  tags = {
    Name = "github-actions-read"
  }
}

resource "aws_iam_role_policy_attachments_exclusive" "github_actions_admin" {
  role_name   = aws_iam_role.github_actions_admin.name
  policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "aws_iam_role_policy_attachments_exclusive" "github_actions_read" {
  role_name = aws_iam_role.github_actions_read.name
  policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    aws_iam_policy.github_actions_read_secretsmanager.arn,
  ]
}

resource "aws_iam_policy" "github_actions_read_secretsmanager" {
  name   = "github-actions-read-secretsmanager"
  path   = "/service/"
  policy = data.aws_iam_policy_document.github_actions_read_secretsmanager.json

  tags = {
    Name = "github-actions-read-secretsmanager"
  }
}

data "aws_iam_policy_document" "github_actions_read_secretsmanager" {
  statement {
    sid = "SecretsManagerRead"

    actions = [
      "secretsmanager:BatchGetSecretValue",
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "arn:aws:secretsmanager:*:${data.aws_caller_identity.current.account_id}:secret:apps/*",
    ]
  }
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

data "aws_iam_policy_document" "arp_github_actions_read" {
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
      values = [
        "repo:lingrino/infra:ref:*",
        "repo:lingrino/infra:pull_request",
        "repo:lingrino/content-archive:ref:*",
        "repo:lingrino/content-archive:pull_request",
      ]
    }
  }
}
