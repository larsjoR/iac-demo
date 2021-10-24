
az account set -s <Subscription ID>

$ResourceGroupName = "Demo-BICEP"

az group create --name $ResourceGroupName --location "West Europe"

$KeyVaultConfig = @{
    someSecretValue = "thisBe super secret"
}

$KeyVaultJson = $KeyVaultConfig | ConvertTo-Json -Compress
$TemplateFile = ".\template.bicep"

$env = "dev"
$secretName = "ApplicationConfig"
$siteName = "bicep"
$siteNameShort = "bic"

az deployment group create `
    -f $TemplateFile `
    -g $ResourceGroupName `
    --parameters environment=$env keyVaultConfigSecretName=$secretName siteName=$siteName siteNameShort=$siteNameShort appConfig=$KeyVaultJson