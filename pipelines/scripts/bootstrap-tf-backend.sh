#!/usr/bin/env bash
set -euo pipefail

PREFIX="cvm"
ENV_NAME="dev"
LOCATION="westeurope"
CONTAINER_NAME="tfstate"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix) PREFIX="$2"; shift 2 ;;
    --env) ENV_NAME="$2"; shift 2 ;;
    --location) LOCATION="$2"; shift 2 ;;
    --container) CONTAINER_NAME="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

STATE_RG="${PREFIX}-${ENV_NAME}-tfstate-rg"
TF_STATE_KEY="${PREFIX}-${ENV_NAME}.tfstate"

az group create --name "$STATE_RG" --location "$LOCATION" --output none

existing_sa=$(az storage account list --resource-group "$STATE_RG" --query "[0].name" -o tsv || true)

if [[ -n "${existing_sa}" ]]; then
  STORAGE_ACCOUNT_NAME="$existing_sa"
else
  suffix=$(tr -dc 'a-z0-9' </dev/urandom | head -c 6)
  base_name=$(echo "${PREFIX}${ENV_NAME}${suffix}" | tr -dc 'a-z0-9')
  STORAGE_ACCOUNT_NAME=$(echo "$base_name" | cut -c1-24)

  az storage account create \
    --name "$STORAGE_ACCOUNT_NAME" \
    --resource-group "$STATE_RG" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --allow-blob-public-access false \
    --output none
fi

account_key=$(az storage account keys list \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --resource-group "$STATE_RG" \
  --query "[0].value" -o tsv)

az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --account-key "$account_key" \
  --output none

echo "##vso[task.setvariable variable=TF_STATE_RG]$STATE_RG"
echo "##vso[task.setvariable variable=TF_STATE_STORAGE]$STORAGE_ACCOUNT_NAME"
echo "##vso[task.setvariable variable=TF_STATE_CONTAINER]$CONTAINER_NAME"
echo "##vso[task.setvariable variable=TF_STATE_KEY]$TF_STATE_KEY"

echo "Backend created/verified:"
echo "  resource_group_name=$STATE_RG"
echo "  storage_account_name=$STORAGE_ACCOUNT_NAME"
echo "  container_name=$CONTAINER_NAME"
echo "  key=$TF_STATE_KEY"
