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
      workspace = "aws-accounts-prod"
    }
  }
}

provider "cloudflare" {
  api_token = jsondecode(ephemeral.aws_secretsmanager_secret_version.cloudflare_keys_terraform_cloud.secret_string)["CLOUDFLARE_API_TOKEN"]
}

provider "cloudflare" {
  alias     = "create-tokens"
  api_token = jsondecode(ephemeral.aws_secretsmanager_secret_version.cloudflare_keys_create_tokens.secret_string)["CLOUDFLARE_API_TOKEN"]
}

provider "github" {
  owner = "lingrino"
  token = jsondecode(ephemeral.aws_secretsmanager_secret_version.github_keys_terraform_cloud.secret_string)["GITHUB_TOKEN"]
}

provider "tailscale" {
  tailnet             = "TYZ1P6RPBi11CNTRL"
  oauth_client_id     = jsondecode(ephemeral.aws_secretsmanager_secret_version.tailscale.secret_string)["TAILSCALE_OAUTH_CLIENT_ID"]
  oauth_client_secret = jsondecode(ephemeral.aws_secretsmanager_secret_version.tailscale.secret_string)["TAILSCALE_OAUTH_CLIENT_SECRET"]
}

provider "tfe" {
  token = jsondecode(ephemeral.aws_secretsmanager_secret_version.terraform_cloud_keys_terraform_cloud.secret_string)["TFE_TOKEN"]
}

#################################
### Terraform                 ###
#################################
terraform {
  cloud {
    organization = "lingrino"

    workspaces {
      name = "aws-accounts-prod"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    github = {
      source = "integrations/github"
    }
    tailscale = {
      source = "tailscale/tailscale"
    }
    tfe = {
      source = "hashicorp/tfe"
    }
  }
}
