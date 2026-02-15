#################################
### Providers                 ###
#################################
provider "aws" {
  region = "us-west-2"

  profile = "auth"

  default_tags {
    tags = {
      terraform = "true"
      workspace = "aws-accounts-auth"
    }
  }
}

#################################
### Terraform                 ###
#################################
terraform {
  backend "s3" {
    bucket              = "lingrino-prod-usw2-terraform-state"
    key                 = "aws/accounts/auth/terraform.tfstate"
    region              = "us-west-2"
    use_lockfile        = true
    profile             = "prod"
    allowed_account_ids = ["840856573771"]
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

#################################
### Remote State              ###
#################################
data "terraform_remote_state" "common_organization" {
  backend = "s3"

  config = {
    bucket              = "lingrino-prod-usw2-terraform-state"
    key                 = "aws/common/organization/terraform.tfstate"
    region              = "us-west-2"
    profile             = "prod"
    allowed_account_ids = ["840856573771"]
  }
}
