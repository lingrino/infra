# https://github.com/terraform-linters/tflint-ruleset-aws/releases
plugin "aws" {
  enabled = true
  version = "0.47.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# https://github.com/terraform-linters/tflint-ruleset-terraform/releases
plugin "terraform" {
  enabled = true
  version = "0.15.0"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

rule "terraform_required_providers" {
  enabled = false
}

rule "terraform_required_version" {
  enabled = false
}

rule "terraform_standard_module_structure" {
  enabled = false
}
