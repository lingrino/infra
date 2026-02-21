module "s3_backup_mini" {
  source = "../../../../terraform-modules/s3//"

  name = "lingrino-prod-usw2-backup-mini"

  enable_object_lock         = true
  enable_intelligent_tiering = false
}

resource "aws_secretsmanager_secret" "backup_mini" {
  name = "aws/iam/users/backup-mini"

  tags = {
    Name = "aws/iam/users/backup-mini"
  }
}

resource "aws_secretsmanager_secret_version" "backup_mini" {
  secret_id = aws_secretsmanager_secret.backup_mini.id
  secret_string = jsonencode({
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.backup_mini.id,
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.backup_mini.secret,
  })
}

resource "aws_iam_user" "backup_mini" {
  name = "backup-mini"
  path = "/service/"

  tags = {
    Name = "backup-mini"
  }
}

resource "aws_iam_access_key" "backup_mini" {
  user = aws_iam_user.backup_mini.name
}

resource "aws_iam_policy_attachment" "backup_mini" {
  name       = "backup-mini"
  users      = [aws_iam_user.backup_mini.name]
  policy_arn = aws_iam_policy.backup_mini.arn
}

resource "aws_iam_policy" "backup_mini" {
  name   = "backup-mini"
  policy = data.aws_iam_policy_document.backup_mini.json
}

data "aws_iam_policy_document" "backup_mini" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetLifecycleConfiguration",
    ]

    resources = [module.s3_backup_mini.arn]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = ["${module.s3_backup_mini.arn}/*"]
  }
}
