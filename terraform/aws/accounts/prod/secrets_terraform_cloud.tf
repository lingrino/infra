#################################
### Terraform Cloud           ###
#################################
resource "aws_secretsmanager_secret" "terraform_cloud_keys_terraform_cloud" {
  name = "terraform-cloud/keys/terraform-cloud"

  tags = {
    Name = "terraform-cloud/keys/terraform-cloud"
  }
}

ephemeral "aws_secretsmanager_secret_version" "terraform_cloud_keys_terraform_cloud" {
  secret_id = aws_secretsmanager_secret.terraform_cloud_keys_terraform_cloud.id
}

#################################
### GitHub                    ###
#################################
resource "aws_secretsmanager_secret" "terraform_cloud_keys_github" {
  name = "terraform-cloud/keys/github"

  tags = {
    Name = "terraform-cloud/keys/github"
  }
}

data "aws_secretsmanager_secret_version" "terraform_cloud_keys_github" {
  secret_id = aws_secretsmanager_secret.terraform_cloud_keys_github.id
}

resource "github_actions_secret" "terraform_cloud" {
  repository      = "infra"
  secret_name     = "TFE_TOKEN"
  plaintext_value = jsondecode(data.aws_secretsmanager_secret_version.terraform_cloud_keys_github.secret_string)["TFE_TOKEN"]
}
