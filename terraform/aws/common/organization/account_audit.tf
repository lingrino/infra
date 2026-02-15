provider "aws" {
  alias  = "audit"
  region = "us-west-2"

  profile = "audit"

  default_tags {
    tags = {
      terraform = "true"
    }
  }
}

module "account_audit" {
  source = "../../../../terraform-modules/account//"

  name  = "audit"
  email = "sean+aws-audit@lingren.com"
}

module "account_audit_base" {
  source = "../../../../terraform-modules/account-base//"

  account_id   = module.account_audit.id
  account_name = module.account_audit.name

  providers = {
    aws = aws.audit
  }
}
