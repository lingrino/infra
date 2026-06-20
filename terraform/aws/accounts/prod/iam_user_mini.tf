resource "aws_secretsmanager_secret" "mini" {
  name = "aws/iam/users/mini"

  tags = {
    Name = "aws/iam/users/mini"
  }
}

resource "aws_secretsmanager_secret_version" "mini" {
  secret_id = aws_secretsmanager_secret.mini.id
  secret_string = jsonencode({
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.mini.id,
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.mini.secret,
  })
}

resource "aws_iam_user" "mini" {
  name = "mini"
  path = "/service/"

  tags = {
    Name = "mini"
  }
}

resource "aws_iam_access_key" "mini" {
  user = aws_iam_user.mini.name
}

resource "aws_iam_policy_attachment" "mini" {
  name       = "mini"
  users      = [aws_iam_user.mini.name]
  policy_arn = aws_iam_policy.mini.arn
}

resource "aws_iam_policy" "mini" {
  name   = "mini"
  policy = data.aws_iam_policy_document.mini.json
}

data "aws_iam_policy_document" "mini" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [aws_secretsmanager_secret.apps_agent_archiver_production.arn]
  }
}
