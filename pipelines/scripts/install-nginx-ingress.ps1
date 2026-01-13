$ErrorActionPreference = 'Stop'

$aksName = $env:AKS_NAME
$aksRg = $env:AKS_RG

if ([string]::IsNullOrWhiteSpace($aksName)) {
  Write-Error 'AKS_NAME environment variable is required.'
  exit 1
}

if ([string]::IsNullOrWhiteSpace($aksRg)) {
  Write-Error 'AKS_RG environment variable is required.'
  exit 1
}

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
  Write-Error 'Azure CLI (az) is required on the agent but was not found in PATH.'
  exit 1
}

if (-not (Get-Command helm -ErrorAction SilentlyContinue)) {
  Write-Error 'Helm is required on the agent but was not found in PATH.'
  exit 1
}

if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
  Write-Error 'kubectl is required on the agent but was not found in PATH.'
  exit 1
}

Write-Host "Getting AKS credentials (admin): $aksRg / $aksName"
az aks get-credentials --admin --resource-group $aksRg --name $aksName --overwrite-existing | Out-Null

Write-Host 'Adding ingress-nginx Helm repo'
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx | Out-Null
helm repo update | Out-Null

Write-Host 'Installing/upgrading ingress-nginx'
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx `
  --namespace ingress-nginx `
  --create-namespace
