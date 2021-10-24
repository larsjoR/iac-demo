Connect-AzAccount -Subscription "<Subscription ID>"

$ResourceGroupName = "Demo-ARM"

Get-AzResourceGroup -Name $ResourceGroupName

New-AzResourceGroup -Name $ResourceGroupName -Location "West Europe"

$KeyVaultConfig = @{
    someSecretValue = "thisBe super secret"
}

$KeyVaultJson = $KeyVaultConfig | ConvertTo-Json -Compress

$TemplateFile = ".\template.json"

$ParametersArm = @{
    environment = "dev"
    keyVaultConfigSecretName = "ApplicationConfig"
    siteName = "demo"
    siteNameShort = "dem"
    appConfig = $KeyVaultJson
}

$ServiceOutput = New-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $TemplateFile `
    -Mode "Incremental" `
    -Verbose `
    -TemplateParameterObject $ParametersArm


# See outputs from deployment 
$ServiceOutput.Outputs



