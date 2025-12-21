# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal infrastructure-as-code repository managing AWS accounts, Cloudflare, GitHub, Tailscale, and Terraform Cloud using Terraform.

## Commands

### Validation (run on PRs)
```bash
terraform fmt -check -diff -recursive     # Check formatting
tflint --init && tflint --config="$(pwd)/.tflint.hcl" --format=compact --recursive  # Lint
```

### Local Development
```bash
terraform fmt -recursive                  # Auto-format all files
cd terraform/<workspace> && terraform init && terraform plan  # Plan changes locally
```

Note: Plans require AWS credentials via profiles (root, prod, audit, auth, dev) or Terraform Cloud dynamic credentials.

## Architecture

### Terraform Cloud Workspaces
All infrastructure runs via Terraform Cloud (org: `lingrino`) with auto-apply on main branch. Each workspace maps to a directory under `terraform/`:

- `terraform/terraform` - Manages TFC org, workspaces, and variable sets (bootstrap workspace)
- `terraform/aws/accounts/{root,audit,auth,dev,prod}` - Per-account AWS resources
- `terraform/aws/common/organization` - AWS Organization and member accounts
- `terraform/cloudflare` - Cloudflare account and DNS
- `terraform/github` - GitHub repositories
- `terraform/tailscale` - Tailscale ACLs, DNS, devices

### Reusable Modules
Located in `terraform-modules/`:
- `account` - Creates AWS Organization member accounts
- `account-base` - Baseline config applied to all AWS accounts (default VPCs, security groups, S3 public access blocks, EBS encryption, IAM OIDC providers)
- `s3` - S3 bucket with optional CloudFront distribution
- `zone` - Route53 hosted zone

### Secrets Management
Provider credentials are stored in AWS Secrets Manager (prod account) and accessed via ephemeral data sources in `meta.tf` files. Pattern: `<service>/keys/terraform-cloud`.

### Workspace Trigger Patterns
Workspaces trigger on changes to their directory AND `terraform-modules/**/*.tf`, ensuring module updates propagate.

## File Naming Conventions

### Standard Files (present in every workspace)
- `meta.tf` - Providers, terraform backend config, required_providers, remote state data sources
- `variables.tf` - Input variables (typically just `tfc_aws_dynamic_credentials` for TFC integration)
- `data.tf` - Shared data sources and locals used across multiple resource files
- `outputs.tf` - Module/workspace outputs
- Resource files are named by `<service/category>_<resource_description>.tf`

### Module Files
Within `terraform-modules/<module>/`:
- `meta.tf` - Required providers only (no backend - modules inherit from root)
- `variables.tf` - Input variables with type, description, and defaults
- `outputs.tf` - Exposed attributes
- Resource files named by function (e.g., `s3.tf`, `cloudfront.tf` in s3 module)

## Code Conventions

### Resource Naming
- Resource names use the logical identifier without redundant prefixes: `aws_s3_bucket.s3`, not `aws_s3_bucket.my_bucket`
- When a file contains multiple related resources, they share a common suffix: `aws_iam_user.backup_arq_mini`, `aws_iam_policy.backup_arq_mini`
- IAM users for services use path `/service/`

### Tags
- All resources get a `Name` tag matching their logical name
- AWS provider `default_tags` adds `terraform = "true"` and `workspace = "<workspace-name>"`

### Provider Configuration
- AWS providers use conditional logic for local vs TFC credentials:
  ```hcl
  profile             = !can(var.tfc_aws_dynamic_credentials.aliases["prod"]) ? "prod" : null
  shared_config_files = try([var.tfc_aws_dynamic_credentials.aliases["prod"].shared_config_file], null)
  ```
- Non-AWS providers fetch credentials from Secrets Manager via ephemeral data sources

### Section Comments
Files use banner comments to separate sections:
```hcl
#################################
### Section Name              ###
#################################
```

### Module Sources
- Local modules use relative paths with trailing double-slash: `source = "../../../../terraform-modules/s3//"`
