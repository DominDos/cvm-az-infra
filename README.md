# cvm-az-infra

Terraform-based Azure infrastructure for **Central vulnerability management (CVM)**.

Key rule for this repo: **Terraform runs only from Azure DevOps Pipelines** (no local `terraform apply`).

## What gets created (dev)
- Workload Resource Group (e.g. `cvm-dev-rg`)
- Log Analytics Workspace
- Azure Container Registry (Standard)
- AKS cluster (PoC settings)
- (Pipeline post-step) ingress-nginx installed via Helm

## How to run

### Canonical pipeline definitions
- Main pipeline (plan/apply): `azure-pipelines.yml` (repo root)
- One-time/manual backend bootstrap: `azure-pipelines-bootstrap.yml` (repo root)

Note: An older pipeline definition previously lived at `pipelines/azure-pipelines.yml` and has been archived to `pipelines/legacy/azure-pipelines.legacy.yml`.

### 1) Bootstrap Terraform remote state (run once, then re-run only if needed)
Run the manual pipeline: `azure-pipelines-bootstrap.yml`.

It creates (if missing) the separate state backend:
- Resource group for state
- Storage account (globally unique)
- Blob container

It prints backend values as Azure DevOps variables:
- `TF_STATE_RG`
- `TF_STATE_STORAGE`
- `TF_STATE_CONTAINER`
- `TF_STATE_KEY`

Store these as **Pipeline variables** or (recommended) in a **Variable Group** so the main pipeline can use them.

### 2) Run the main infra pipeline
Pipeline: `azure-pipelines.yml`
- PRs and `main`: **Plan** stage
- `main` only: **Apply** stage (deployment job) using environment `cvm-dev` (approvals placeholder)

## Required Azure DevOps configuration

### Service connection
- Azure Resource Manager service connection name (placeholder): `SC-AZURE`

### Variables / variable group
These must exist for the main pipeline:
- `TF_STATE_RG`
- `TF_STATE_STORAGE`
- `TF_STATE_CONTAINER`
- `TF_STATE_KEY`

Notes:
- `ARM_*` variables are not required here because Terraform runs inside `AzureCLI@2` tasks and authenticates via the Azure CLI login provided by the service connection.

## Naming conventions
Defaults are driven by `prefix` and `env`:
- Workload RG: `${prefix}-${env}-rg`
- AKS: `${prefix}-${env}-aks`
- Log Analytics: `${prefix}-${env}-law`
- ACR: `${prefix}${env}acr` (must be globally unique; adjust if needed)

## Outputs (for downstream repos)
Terraform outputs include:
- `resource_group_name`
- `aks_name`
- `aks_node_resource_group`
- `acr_name`
- `acr_login_server`
- `log_analytics_workspace_id`
- `aks_egress_public_ip`

These are intended to be consumed by app/platform repos (e.g., for AKS deployment targets and ACR references).

## Lessons learned

- If AKS-ingress provisioning fails with `LinkedAuthorizationFailed` related to `Microsoft.Network/publicIPAddresses/join/action`, grant the AKS identity permission on the Public IP scope.
- This repo codifies that fix in `terraform/envs/dev/main.tf` via `azurerm_role_assignment` (role: `Network Contributor`) on the egress Public IP.
