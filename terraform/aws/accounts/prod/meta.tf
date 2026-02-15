#################################
### Providers                 ###
#################################
provider "aws" {
  region = "us-west-2"

  profile = "prod"

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

#################################
### Terraform                 ###
#################################
terraform {
  backend "s3" {
    bucket              = "lingrino-prod-usw2-terraform-state"
    key                 = "aws/accounts/prod/terraform.tfstate"
    region              = "us-west-2"
    use_lockfile        = true
    profile             = "prod"
    allowed_account_ids = ["840856573771"]
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
  }
}
