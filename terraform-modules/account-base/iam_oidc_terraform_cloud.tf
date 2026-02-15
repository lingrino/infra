data "tls_certificate" "terraform_cloud" {
  url = "https://app.terraform.io"
}

resource "aws_iam_openid_connect_provider" "terraform_cloud" {
  url             = "https://app.terraform.io"
  client_id_list  = ["aws.workload.identity"]
  thumbprint_list = [data.tls_certificate.terraform_cloud.certificates[0].sha1_fingerprint]

  tags = {
    Name = "terraform-cloud"
  }
}

resource "aws_iam_role" "terraform_cloud" {
  name = "terraform-cloud"
  path = "/service/"

  assume_role_policy = data.aws_iam_policy_document.arp_terraform_cloud.json

  tags = {
    Name = "terraform-cloud"
  }
}

resource "aws_iam_role_policy_attachments_exclusive" "terraform_cloud_administrator" {
  role_name   = aws_iam_role.terraform_cloud.name
  policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

data "aws_iam_policy_document" "arp_terraform_cloud" {
  statement {
    sid = "OIDCTerraformCloud"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.terraform_cloud.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "app.terraform.io:aud"
      values   = ["aws.workload.identity"]
    }

    condition {
      test     = "StringLike"
      variable = "app.terraform.io:sub"
      values   = ["organization:lingrino:project:main:workspace:*:run_phase:*"]
    }
  }
}
