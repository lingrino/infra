data "aws_iam_policy_document" "terraform_state" {
  statement {
    sid    = "DenyDeleteObjectVersion"
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:DeleteObjectVersion",
    ]

    resources = [
      "___ARN___/*",
    ]
  }

  statement {
    sid    = "DenySuspendVersioning"
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutBucketVersioning",
    ]

    resources = [
      "___ARN___",
    ]
  }
}

module "s3_terraform_state" {
  source = "../../../../terraform-modules/s3//"

  name   = "lingrino-prod-usw2-terraform-state"
  policy = data.aws_iam_policy_document.terraform_state.json
}
