#################################
### Providers                 ###
#################################
provider "aws" {
  region = "us-west-2"

  profile = "audit"

  default_tags {
    tags = {
      terraform = "true"
      workspace = "aws-accounts-audit"
    }
  }
}

#################################
### Terraform                 ###
#################################
terraform {
  backend "s3" {
    bucket              = "lingrino-prod-usw2-terraform-state"
    key                 = "aws/accounts/audit/terraform.tfstate"
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
