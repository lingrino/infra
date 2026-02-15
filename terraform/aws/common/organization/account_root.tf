provider "aws" {
  alias  = "root"
  region = "us-west-2"

  profile = "root"

  default_tags {
    tags = {
      terraform = "true"
      workspace = "aws-common-organization"
    }
  }
}

module "account_root" {
  source = "../../../../terraform-modules/account//"

  name  = "root"
  email = "sean+aws-root@lingren.com"
}

module "account_root_base" {
  source = "../../../../terraform-modules/account-base//"

  account_id   = module.account_root.id
  account_name = module.account_root.name

  providers = {
    aws = aws.root
  }
}
