#################################
### Providers                 ###
#################################
provider "aws" {
  region = "us-west-2"

  profile = "prod"

  default_tags {
    tags = {
      terraform = "true"
      workspace = "github"
    }
  }
}

ephemeral "aws_secretsmanager_secret_version" "github" {
  secret_id = "github/keys/infra"
}

provider "github" {
  owner = "lingrino"
  token = jsondecode(ephemeral.aws_secretsmanager_secret_version.github.secret_string)["GITHUB_TOKEN"]
}

#################################
### Terraform                 ###
#################################
terraform {
  backend "s3" {
    bucket              = "lingrino-prod-usw2-terraform-state"
    key                 = "github/terraform.tfstate"
    region              = "us-west-2"
    use_lockfile        = true
    profile             = "prod"
    allowed_account_ids = ["840856573771"]
  }

  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}
