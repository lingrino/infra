#################################
### Providers                 ###
#################################
provider "aws" {
  region = "us-west-2"

  profile = "prod"

  default_tags {
    tags = {
      terraform = "true"
      workspace = "cloudflare"
    }
  }
}

ephemeral "aws_secretsmanager_secret_version" "cloudflare" {
  secret_id = "cloudflare/keys/terraform-cloud"
}

provider "cloudflare" {
  api_token = jsondecode(ephemeral.aws_secretsmanager_secret_version.cloudflare.secret_string)["CLOUDFLARE_API_TOKEN"]
}

#################################
### Terraform                 ###
#################################
terraform {
  backend "s3" {
    bucket              = "lingrino-prod-usw2-terraform-state"
    key                 = "cloudflare/terraform.tfstate"
    region              = "us-west-2"
    use_lockfile        = true
    profile             = "prod"
    allowed_account_ids = ["840856573771"]
  }

  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}
