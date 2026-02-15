provider "aws" {
  alias  = "dev"
  region = "us-west-2"

  profile = "dev"

  default_tags {
    tags = {
      terraform = "true"
      workspace = "aws-common-organization"
    }
  }
}

module "account_dev" {
  source = "../../../../terraform-modules/account//"

  name  = "dev"
  email = "sean+aws-dev@lingren.com"
}

module "account_dev_base" {
  source = "../../../../terraform-modules/account-base//"

  account_id   = module.account_dev.id
  account_name = module.account_dev.name

  providers = {
    aws = aws.dev
  }
}
