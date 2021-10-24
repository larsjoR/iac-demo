@allowed([
  'dev'
  'qa'
  'prod'
  'test'
  'stg'
])
@description('')
param environment string = 'dev'

@description('The JSON application configuration value')
param appConfig string

@description('Name of azure web app')
param siteName string

@description('Name of azure web app (shortened)')
param siteNameShort string

@allowed([
  'Basic'
  'Standard'
])
param serverfarmsSkuTier string = 'Basic'

@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P4'
])
param serverfarmsSkuName string = 'B1'

@description('The name application configuration keyvault secret name')
param keyVaultConfigSecretName string

var keyVaultName_var = 'demo-${environment}-${siteNameShort}-kv'
var appSiteName_var = 'demo-${environment}-tst-${siteName}-wa'
var hostingPlanName_var = 'demo-${environment}-tst-${siteName}-sp'
var appInsightsName_var = 'demo-${environment}-${siteName}-ai'
var identityResourceId = '${appSiteName.id}/providers/Microsoft.ManagedIdentity/Identities/default'

resource hostingPlanName 'Microsoft.Web/serverfarms@2016-09-01' = {
  name: hostingPlanName_var
  location: resourceGroup().location
  properties: {
    name: hostingPlanName_var
    reserved: false
  }
  sku: {
    tier: serverfarmsSkuTier
    name: serverfarmsSkuName
  }
  kind: 'app'
  tags: {
    displayName: 'HostingPlan'
    createdBy: 'Me'
  }
}

resource appSiteName 'Microsoft.Web/sites@2016-08-01' = {
  name: appSiteName_var
  location: resourceGroup().location
  tags: {
    displayName: 'HostingPlan'
    createdBy: 'Me'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlanName_var
    clientAffinityEnabled: true
    enabled: true
    reserved: false
    httpsOnly: true
    clientCertEnabled: false
    siteConfig: {
      phpVersion: '7.2'
      nodeVersion: '10.6.0'
      requestTracingEnabled: true
      httpLoggingEnabled: true
      logsDirectorySizeLimit: 100
      detailedErrorLoggingEnabled: true
      use32BitWorkerProcess: false
      alwaysOn: true
      http20Enabled: true
      appSettings: [
        {
          name: 'SCM_ZIPDEPLOY_DONOT_PRESERVE_FILETIME'
          value: '1'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(appInsightsName.id, '2015-05-01').InstrumentationKey
        }
        {
          name: 'WEBSITE_LOAD_CERTIFICATES'
          value: '*'
        }
        {
          name: 'KeyVaultConfigUrl'
          value: 'https://${keyVaultName_var}.vault.azure.net/secrets/${keyVaultConfigSecretName}'
        }
        {
          name: 'UseKeyVault'
          value: 'true'
        }
        {
          name: 'Logging:LogLevel:Default'
          value: 'Warning'
        }
      ]
      connectionStrings: []
    }
  }
  dependsOn: [
    hostingPlanName
  ]
}

resource appSiteName_logs 'Microsoft.Web/sites/config@2016-08-01' = {
  name: '${appSiteName.name}/logs'
  properties: {
    applicationLogs: {
      fileSystem: {
        level: 'Warning'
      }
      azureBlobStorage: {
        level: 'Verbose'
        sasUrl: null
        retentionInDays: null
        enabled: false
      }
    }
    httpLogs: {
      fileSystem: {
        retentionInMb: 100
        retentionInDays: 60
        enabled: true
      }
      azureBlobStorage: {
        sasUrl: null
        retentionInDays: null
        enabled: false
      }
    }
    failedRequestsTracing: {
      enabled: true
    }
    detailedErrorMessages: {
      enabled: true
    }
  }
}

resource appInsightsName 'Microsoft.Insights/components@2015-05-01' = {
  name: appInsightsName_var
  location: resourceGroup().location
  kind: 'web'
  tags: {
    displayName: 'HostingPlan'
    createdBy: 'Me'
  }
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
  }
}

resource keyVaultName 'Microsoft.KeyVault/vaults@2015-06-01' = {
  name: keyVaultName_var
  location: resourceGroup().location
  tags: {
    displayName: 'HostingPlan'
    createdBy: 'Me'
  }
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    accessPolicies: [
      {
        tenantId: reference(identityResourceId, '2015-08-31-PREVIEW').tenantId
        objectId: reference(identityResourceId, '2015-08-31-PREVIEW').principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

resource keyVaultName_keyVaultConfigSecretName 'Microsoft.KeyVault/vaults/secrets@2015-06-01' = {
  name: '${keyVaultName.name}/${keyVaultConfigSecretName}'
  tags: {
    displayName: 'KeyVault Config'
  }
  properties: {
    contentType: 'application/json'
    value: appConfig
  }
}

output siteUri string = reference('Microsoft.Web/sites/${appSiteName_var}').hostnames[0]
output siteName string = appSiteName_var
output webAppPrincipalId string = reference(identityResourceId, '2015-08-31-PREVIEW').principalId
output keyVaultName string = keyVaultName_var
