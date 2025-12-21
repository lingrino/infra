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
