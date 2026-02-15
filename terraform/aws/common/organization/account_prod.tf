provider "aws" {
  alias  = "prod"
  region = "us-west-2"

  profile = "prod"

  default_tags {
    tags = {
      terraform = "true"
      workspace = "aws-common-organization"
    }
  }
}

module "account_prod" {
  source = "../../../../terraform-modules/account//"

  name  = "prod"
  email = "sean+aws-prod@lingren.com"
}

module "account_prod_base" {
  source = "../../../../terraform-modules/account-base//"

  account_id   = module.account_prod.id
  account_name = module.account_prod.name

  providers = {
    aws = aws.prod
  }
}
