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
