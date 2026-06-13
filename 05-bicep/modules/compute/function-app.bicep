// modules/compute/function-app.bicep
// Azure Functions voor Contoso Manufacturing
// Scheduler, Processor, Reporter — draaien op App Service Plan

// ── Parameters ────────────────────────────────────────────────────────

@description('Azure region')
param location string

@description('Function App name')
param functionAppName string

@description('App Service Plan resource ID')
param appServicePlanId string

@description('Storage Account name voor Functions runtime')
param storageAccountName string

@description('Key Vault name voor secret references')
param keyVaultName string

@description('VNet subnet ID voor VNet Integration')
param vnetSubnetId string

@description('Log Analytics Workspace ID for diagnostics')
param logAnalyticsWorkspaceId string = ''

@description('Tags')
param tags object

// ── Storage Account Reference ─────────────────────────────────────────

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// ── Function App ──────────────────────────────────────────────────────

resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'               // Managed Identity voor Key Vault toegang
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    virtualNetworkSubnetId: vnetSubnetId
    siteConfig: {
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v4.0'        // .NET Framework voor Windows Services migratie
      use32BitWorkerProcess: false
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: '1'
        }
        {
          // SAP API key via Key Vault reference
          name: 'SapApiKey'
          value: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/sap-api-key/)'
        }
        {
          // SMTP password via Key Vault reference
          name: 'SmtpPassword'
          value: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/smtp-password/)'
        }
        {
          // SQL connection string via Key Vault reference
          name: 'ConnectionStrings__SqlDatabase'
          value: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/sql-connection-string/)'
        }
      ]
    }
  }
}

// ── Diagnostics ───────────────────────────────────────────────────────

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: 'diag-${functionAppName}'
  scope: functionApp
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'FunctionAppLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// ── Outputs ───────────────────────────────────────────────────────────

output functionAppName string = functionApp.name
output functionAppId string = functionApp.id
output principalId string = functionApp.identity.principalId
