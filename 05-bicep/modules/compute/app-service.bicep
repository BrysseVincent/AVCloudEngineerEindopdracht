// modules/compute/app-service.bicep
// App Service voor Contoso Manufacturing
// Inclusief: Managed Identity, VNet Integration, HTTPS only, Key Vault references

// ── Parameters ────────────────────────────────────────────────────────

@description('Azure region')
param location string

@description('App Service name')
param appName string

@description('App Service Plan resource ID')
param appServicePlanId string

@description('Key Vault name for secret references')
param keyVaultName string

@description('VNet subnet ID for VNet Integration')
param vnetSubnetId string

@description('Environment: dev, tst, prd')
@allowed(['dev', 'tst', 'prd'])
param environment string = 'prd'

@description('Log Analytics Workspace ID for diagnostics')
param logAnalyticsWorkspaceId string = ''

@description('Tags')
param tags object

// ── Variables ─────────────────────────────────────────────────────────

var isProduction = environment == 'prd'

// ── App Service ───────────────────────────────────────────────────────

resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: appName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'                 // Managed Identity voor Key Vault toegang
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true                        // HTTPS only - Azure Policy vereiste
    virtualNetworkSubnetId: vnetSubnetId   // VNet Integration
    siteConfig: {
      minTlsVersion: '1.2'                 // Minimum TLS 1.2 - Azure Policy vereiste
      alwaysOn: isProduction               // Always On enkel in prd
      healthCheckPath: '/health'
      netFrameworkVersion: 'v4.0'          // ASP.NET WebForms 4.7
      use32BitWorkerProcess: false
      appSettings: [
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          // SQL connection string via Key Vault reference
          name: 'ConnectionStrings__SqlDatabase'
          value: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/sql-connection-string/)'
        }
        {
          // SAP API key via Key Vault reference
          name: 'SapApiKey'
          value: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/sap-api-key/)'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/appinsights-connection-string/)'
        }
        {
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: '1'                       // Alle traffic via VNet
        }
      ]
    }
  }
}

// ── Staging Slot (prd only) ───────────────────────────────────────────

resource stagingSlot 'Microsoft.Web/sites/slots@2023-01-01' = if (isProduction) {
  name: 'staging'
  parent: appService
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    virtualNetworkSubnetId: vnetSubnetId
    siteConfig: {
      minTlsVersion: '1.2'
      alwaysOn: false                      // Staging hoeft niet always on
      healthCheckPath: '/health'
      netFrameworkVersion: 'v4.0'
    }
  }
}

// ── Diagnostics ───────────────────────────────────────────────────────

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: 'diag-${appName}'
  scope: appService
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
      }
      {
        category: 'AppServiceAuditLogs'
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

output appName string = appService.name
output appId string = appService.id
output principalId string = appService.identity.principalId
output defaultHostname string = appService.properties.defaultHostName
