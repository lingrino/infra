provider "aws" {
  alias  = "auth"
  region = "us-west-2"

  profile = "auth"

  default_tags {
    tags = {
      terraform = "true"
      workspace = "aws-common-organization"
    }
  }
}

module "account_auth" {
  source = "../../../../terraform-modules/account//"

  name  = "auth"
  email = "sean+aws-auth@lingren.com"
}

module "account_auth_base" {
  source = "../../../../terraform-modules/account-base//"

  account_id   = module.account_auth.id
  account_name = module.account_auth.name

  providers = {
    aws = aws.auth
  }
}
