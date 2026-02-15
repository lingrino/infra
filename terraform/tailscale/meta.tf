# trigger plan

#################################
### Providers                 ###
#################################
provider "aws" {
  region = "us-west-2"

  profile = "prod"

  default_tags {
    tags = {
      terraform = "true"
      workspace = "tailscale"
    }
  }
}

ephemeral "aws_secretsmanager_secret_version" "tailscale" {
  secret_id = "tailscale/keys/infra"
}

provider "tailscale" {
  tailnet             = "TYZ1P6RPBi11CNTRL"
  oauth_client_id     = jsondecode(ephemeral.aws_secretsmanager_secret_version.tailscale.secret_string)["TAILSCALE_OAUTH_CLIENT_ID"]
  oauth_client_secret = jsondecode(ephemeral.aws_secretsmanager_secret_version.tailscale.secret_string)["TAILSCALE_OAUTH_CLIENT_SECRET"]
}

#################################
### Terraform                 ###
#################################
terraform {
  backend "s3" {
    bucket              = "lingrino-prod-usw2-terraform-state"
    key                 = "tailscale/terraform.tfstate"
    region              = "us-west-2"
    use_lockfile        = true
    profile             = "prod"
    allowed_account_ids = ["840856573771"]
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    tailscale = {
      source = "tailscale/tailscale"
    }
  }
}
