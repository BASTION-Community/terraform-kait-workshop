# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Educational Terraform workshop ("Terraform으로 배우는 AWS 인프라 관리") teaching AWS infrastructure through three progressive steps: single-file → modularized → multi-environment. Step 3 dev includes ALB + EC2 (nginx) with HTTPS and custom domain. Target audience: KAIT ISMS auditors. Documentation is in Korean.

## Common Commands

Each step is an independent Terraform root module. Always `cd` into the target directory first.

```bash
# Step 1
cd step1-single-file && terraform init && terraform plan

# Step 2
cd step2-module && terraform init && terraform plan

# Step 3 (per-environment)
cd step3-environments/environments/dev && terraform init && terraform plan
cd step3-environments/environments/stg && terraform init && terraform plan

# Apply / Destroy (any step)
terraform apply
terraform destroy -auto-approve
```

## Architecture

The three steps demonstrate an evolution pattern:

- **step1-single-file/** — All resources in `main.tf`. Simplest form, no variables or modules. 5 resources (VPC, Subnet, IGW, Route Table, RT Association).
- **step2-module/** — Root `main.tf` calls `modules/vpc/` with variables. Single backend/state.
- **step3-environments/** — Shared `modules/vpc/` referenced by isolated `environments/{dev,stg}/` directories, each with its own state and backend.
  - **dev** has additional resources beyond the VPC module: second public subnet (for ALB multi-AZ), Security Groups, EC2 (nginx), ALB, Target Group, Listeners (HTTPS + HTTP redirect), Route 53 record. Total: 16 resources.
  - **stg** has VPC module only. Total: 5 resources.

In step3, environment directories use relative source paths (`../../modules/vpc`) to the shared module. TFC Working Directory must be set to the environment path (e.g., `step3-environments/environments/dev`).

## Key Configuration

- **AWS Region:** ap-northeast-2 (Seoul)
- **Terraform:** ≥1.0.0, AWS provider ~5.0
- **Backend:** Terraform Cloud (organization: meiko_Org)
- **CIDR scheme:** dev=10.10.0.0/16 (subnets: .1.0/24, .2.0/24), stg=10.11.0.0/16, prd=10.12.0.0/16
- **Domain:** kait.meiko.co.kr → ALB (dev only)
- **ACM/Route53:** Managed externally, referenced via variables (`acm_certificate_arn`, `route53_zone_id`, `domain_name`)

## TFC Workspaces

| Workspace | Working Directory | Usage |
|---|---|---|
| kait-terraform | `step1-single-file` or `step2-module` | Step 1, 2 (shared, destroy between steps) |
| kait-terraform-dev | `step3-environments/environments/dev` | Step 3 dev |
| kait-terraform-stg | `step3-environments/environments/stg` | Step 3 stg |

## Step 3 Dev File Organization

- `main.tf` — VPC module call + additional subnet for ALB
- `ec2.tf` — AMI data source, Security Groups, EC2, ALB, Target Group, Listeners, Route 53
- `outputs.tf` — All output blocks
- `variables.tf` — Variable declarations
- `terraform.tfvars` — Variable values
- `terraform.tf` — Provider and version constraints
- `backend.tf` — TFC backend config

## Conventions

- Resource naming: `${var.environment}-resource-type` (e.g., `dev-vpc`, `dev-alb-sg`)
- Step 3 uses provider-level `default_tags` for Project/Environment/ManagedBy
- Tags are merged in the VPC module using `locals { common_tags = merge(...) }`
- EC2 uses `associate_public_ip_address = true` explicitly (not relying on subnet default)

## Documentation Rules

- Use **mermaid diagrams** for visual representations (no ASCII art)
- Diagram types: `graph TD/LR` for structure, `sequenceDiagram` for flows, `subgraph` for grouping
- Use `<br>` for line breaks in mermaid nodes (no `\n` or `"`)
- No colors (style, classDef) — use default theme
- Tables, file trees, code blocks use markdown
