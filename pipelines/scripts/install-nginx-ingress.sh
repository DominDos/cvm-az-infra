#!/usr/bin/env bash
set -euo pipefail

: "${AKS_NAME:?AKS_NAME environment variable is required}"
: "${AKS_RG:?AKS_RG environment variable is required}"

if ! command -v helm >/dev/null 2>&1; then
  curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod +x /tmp/get_helm.sh
  /tmp/get_helm.sh
fi

az aks get-credentials --admin --resource-group "$AKS_RG" --name "$AKS_NAME" --overwrite-existing

kubectl create namespace ingress-nginx --dry-run=client -o yaml | kubectl apply -f -

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace
