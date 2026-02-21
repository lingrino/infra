# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal infrastructure-as-code repository managing AWS accounts, Cloudflare, GitHub, Tailscale, and other services using Terraform.

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

Note: Plans and applies are run locally. AWS credentials are provided via profiles (root, prod, audit, auth, dev). The `prod` profile is always required for state access (see State Management below).

## Architecture

### Workspaces
Each workspace maps to a directory under `terraform/`. Plans and applies are run locally:

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

### State Management
Terraform state is stored in S3 in the prod account (`lingrino-prod-usw2-terraform-state`). All workspaces use `profile = "prod"` in their backend config for state access, separate from the provider credentials. State keys follow the pattern `<workspace-path>/terraform.tfstate` (e.g., `aws/accounts/dev/terraform.tfstate`). S3 native lock files are used for locking (`use_lockfile = true`).

### Secrets Management
Provider credentials are stored in AWS Secrets Manager (prod account) and accessed via ephemeral data sources in `meta.tf` files. Pattern: `<service>/keys/<name>`.

## File Naming Conventions

### Standard Files (present in every workspace)
- `meta.tf` - Providers, terraform backend config, required_providers, remote state data sources
- `variables.tf` - Input variables
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
- When a file contains multiple related resources, they share a common suffix: `aws_iam_user.backup_mini`, `aws_iam_policy.backup_mini`
- IAM users for services use path `/service/`

### Tags
- All resources get a `Name` tag matching their logical name
- AWS provider `default_tags` adds `terraform = "true"` and `workspace = "<workspace-name>"`

### Provider Configuration
- AWS providers use named profiles: `profile = "dev"`, `profile = "prod"`, etc.
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
