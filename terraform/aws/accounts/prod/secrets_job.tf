resource "aws_secretsmanager_secret" "apps_job_ci" {
  name = "apps/job/ci"

  tags = {
    Name = "apps/job/ci"
  }
}

data "aws_secretsmanager_secret_version" "apps_job_ci" {
  secret_id = aws_secretsmanager_secret.apps_job_ci.id
}

resource "github_actions_secret" "apps_job_ci_oai_key" {
  repository  = "job"
  secret_name = "OPENAI_API_KEY"
  value       = jsondecode(data.aws_secretsmanager_secret_version.apps_job_ci.secret_string)["OPENAI_API_KEY"]
}

resource "github_actions_secret" "apps_job_ci_resend_key" {
  repository  = "job"
  secret_name = "RESEND_API_KEY"
  value       = jsondecode(data.aws_secretsmanager_secret_version.apps_job_ci.secret_string)["RESEND_API_KEY"]
}
