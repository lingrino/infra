#################################
### Providers                 ###
#################################
provider "aws" {
  region = "us-west-2"

  profile             = !can(var.tfc_aws_dynamic_credentials.aliases["prod"]) ? "prod" : null
  shared_config_files = try([var.tfc_aws_dynamic_credentials.aliases["prod"].shared_config_file], null)

  default_tags {
    tags = {
      terraform = "true"
      workspace = "tailscale"
    }
  }
}

ephemeral "aws_secretsmanager_secret_version" "tailscale" {
  secret_id = "tailscale/keys/terraform-cloud"
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
  cloud {
    organization = "lingrino"

    workspaces {
      name = "tailscale"
    }
  }

  required_providers {
    tailscale = {
      source = "tailscale/tailscale"
    }
  }
}
