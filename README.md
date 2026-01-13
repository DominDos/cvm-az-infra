<<<<<<< HEAD
# platform-infra

Azure DevOps Project: `platform-infra`  
Repo: `platform-infra`

This repo is the **single source of truth** for shared Azure platform resources used by apps and shared services.

## What this repo owns
- Terraform provisioning of Azure resources:
  - AKS
  - ACR
  - (optional) Key Vault, Log Analytics, networking primitives
- A pipeline that runs `terraform validate/plan/apply` (no local applies)
- A published, non-secret **outputs contract** consumed by downstream pipelines

## Non-goals
- Application deployments (Helm for apps lives in each app repo)
- DefectDojo Helm deployment (lives in `defectdojo-platform`)

## Outputs contract (consumed by other projects)
Downstream pipelines must be able to consume these **non-secret** outputs:

- `AZURE_RG` (AKS resource group)
- `AKS_NAME`
- `ACR_NAME`
- `ACR_LOGIN_SERVER` (e.g. `myacr.azurecr.io`)

### Artifact format
The infra pipeline publishes a pipeline artifact named `infra-outputs` containing:
- `out/infra_outputs.env` (KEY=VALUE)
- `out/infra_outputs.json` (optional debug, `terraform output -json`)

Example `infra_outputs.env`:
```text
AZURE_RG=potatobankpoc-rg
AKS_NAME=potatobankpoc-aks
ACR_NAME=potatobankpocxxxxxx
ACR_LOGIN_SERVER=potatobankpocxxxxxx.azurecr.io
```

## Secrets and identity
- Do not publish kubeconfig, passwords, or tokens as outputs/artifacts.
- The pipeline authenticates using an Azure DevOps service connection (placeholder variable).

## Pipelines
Suggested pipeline names in ADO:
- `platform-infra-terraform-main`

See `pipelines/azure-pipelines.yml`.

## Current repo mapping (from legacy monorepo)
This repo is expected to absorb content currently under:
- `infra/terraform/` (Terraform root)

See top-level `MIGRATION.md` for the detailed mapping and split steps.
=======
# cvm-az-infra

Terraform-based Azure infrastructure for **Centralni vulnerability management (CVM)**.

Key rule for this repo: **Terraform runs only from Azure DevOps Pipelines** (no local `terraform apply`).

## What gets created (dev)
- Workload Resource Group (e.g. `cvm-dev-rg`)
- Log Analytics Workspace
- Azure Container Registry (Standard)
- AKS cluster (PoC settings)
- (Pipeline post-step) ingress-nginx installed via Helm

## How to run

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

These are intended to be consumed by app/platform repos (e.g., for AKS deployment targets and ACR references).
>>>>>>> ed8778f (Initial infra scaffold (Terraform + ADO pipelines + scripts))
