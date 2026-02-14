module "s3_backup_arq_mini" {
  source = "../../../../terraform-modules/s3//"

  name = "lingrino-prod-usw2-backup-arq-mini"

  enable_object_lock         = true
  enable_intelligent_tiering = false
}

resource "aws_secretsmanager_secret" "backup_arq_mini" {
  name = "aws/iam/users/backup-arq-mini"

  tags = {
    Name = "aws/iam/users/backup-arq-mini"
  }
}

resource "aws_secretsmanager_secret_version" "backup_arq_mini" {
  secret_id = aws_secretsmanager_secret.backup_arq_mini.id
  secret_string = jsonencode({
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.backup_arq_mini.id,
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.backup_arq_mini.secret,
  })
}

resource "aws_iam_user" "backup_arq_mini" {
  name = "backup-arq-mini"
  path = "/service/"

  tags = {
    Name = "backup-arq-mini"
  }
}

resource "aws_iam_access_key" "backup_arq_mini" {
  user = aws_iam_user.backup_arq_mini.name
}

resource "aws_iam_policy_attachment" "backup_arq_mini" {
  name       = "backup-arq-mini"
  users      = [aws_iam_user.backup_arq_mini.name]
  policy_arn = aws_iam_policy.backup_arq_mini.arn
}

resource "aws_iam_policy" "backup_arq_mini" {
  name   = "backup-arq-mini"
  policy = data.aws_iam_policy_document.backup_arq_mini.json
}

data "aws_iam_policy_document" "backup_arq_mini" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetLifecycleConfiguration",
    ]

    resources = [module.s3_backup_arq_mini.arn]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = ["${module.s3_backup_arq_mini.arn}/*"]
  }
}
