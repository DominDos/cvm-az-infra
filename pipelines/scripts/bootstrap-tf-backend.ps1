param(
  [Parameter(Mandatory = $false)]
  [string]$Prefix = 'cvm',

  [Parameter(Mandatory = $false)]
  [string]$EnvName = 'dev',

  [Parameter(Mandatory = $false)]
  [string]$Location = 'westeurope',

  [Parameter(Mandatory = $false)]
  [string]$Container = 'tfstate'
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
  Write-Error 'Azure CLI (az) is required on the agent but was not found in PATH.'
  exit 1
}

$stateRg = "$Prefix-$EnvName-tfstate-rg"
$tfStateKey = "$Prefix-$EnvName.tfstate"

az group create --name $stateRg --location $Location --output none | Out-Null

$existingSa = (az storage account list --resource-group $stateRg --query "[0].name" -o tsv)

if (-not [string]::IsNullOrWhiteSpace($existingSa)) {
  $storageAccountName = $existingSa
}
else {
  $chars = @('a'..'z') + @('0'..'9')
  $suffix = -join (1..6 | ForEach-Object { $chars | Get-Random })

  $base = ($Prefix + $EnvName + $suffix).ToLower() -replace '[^a-z0-9]', ''
  if ($base.Length -gt 24) { $base = $base.Substring(0, 24) }
  $storageAccountName = $base

  az storage account create `
    --name $storageAccountName `
    --resource-group $stateRg `
    --location $Location `
    --sku Standard_LRS `
    --kind StorageV2 `
    --allow-blob-public-access false `
    --output none | Out-Null
}

$accountKey = (az storage account keys list --account-name $storageAccountName --resource-group $stateRg --query "[0].value" -o tsv)

az storage container create `
  --name $Container `
  --account-name $storageAccountName `
  --account-key $accountKey `
  --output none | Out-Null

Write-Host "##vso[task.setvariable variable=TF_STATE_RG]$stateRg"
Write-Host "##vso[task.setvariable variable=TF_STATE_STORAGE]$storageAccountName"
Write-Host "##vso[task.setvariable variable=TF_STATE_CONTAINER]$Container"
Write-Host "##vso[task.setvariable variable=TF_STATE_KEY]$tfStateKey"
Write-Host "##vso[task.setvariable variable=TF_STATE_ACCESS_KEY;issecret=true]$accountKey"

Write-Host 'Backend created/verified:'
Write-Host "  resource_group_name=$stateRg"
Write-Host "  storage_account_name=$storageAccountName"
Write-Host "  container_name=$Container"
Write-Host "  key=$tfStateKey"
