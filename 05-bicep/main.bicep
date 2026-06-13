// main.bicep — Contoso Manufacturing Azure Infrastructure
// delaware cloud practice

targetScope = 'subscription'

// ──────────────────────────────────────────────
// Parameters
// ──────────────────────────────────────────────

@description('Environment: dev, tst, prd')
@allowed(['dev', 'tst', 'prd'])
param environment string

@description('Primary Azure region')
param location string = 'westeurope'

@description('Short location code for naming')
param locationCode string = 'weu'

@description('Application name')
param appName string = 'contoso'

@description('Tags to apply to all resources')
param tags object = {
  Environment: environment
  Application: appName
  Owner: 'team-cloud@contoso.be'
  CostCenter: 'CC-IT-001'
  DataClassification: 'internal'
  ManagedBy: 'bicep'
}

@description('Private DNS zone ID for SQL private endpoint (privatelink.database.windows.net)')
param privateDnsZoneSqlId string

@description('Private DNS zone ID for Key Vault private endpoint (privatelink.vaultcore.azure.net)')
param privateDnsZoneKvId string

@description('Private DNS zone ID for Storage Blob private endpoint (privatelink.blob.core.windows.net)')
param privateDnsZoneStorageBlobId string

// ── SKU Parameters — omgevingsspecifieke waarden komen uit param files ─

@description('App Service Plan SKU — P2v3 voor prd, S2 voor tst, B1 voor dev')
@allowed(['P2v3', 'P3v3', 'S2', 'S3', 'B1', 'B2', 'B3'])
param appServiceSku string = 'P2v3'

@description('SQL Database SKU — GP_Gen5_4 voor prd, GP_Gen5_2 voor tst, GP_S_Gen5_2 voor dev (serverless)')
@allowed(['GP_Gen5_4', 'GP_Gen5_2', 'GP_S_Gen5_2'])
param sqlSku string = 'GP_Gen5_4'

@description('SQL Database max grootte in GB')
@minValue(1)
@maxValue(4096)
param sqlMaxSizeGB int = 500

@description('Storage Account SKU — Standard_GRS voor prd, Standard_LRS voor dev/tst')
@allowed(['Standard_GRS', 'Standard_LRS', 'Standard_ZRS'])
param storageSku string = 'Standard_GRS'

// ──────────────────────────────────────────────
// Variables
// ──────────────────────────────────────────────

var prefix = '${appName}-${environment}'
var hubVnetAddressPrefix = '10.0.0.0/16'
var spokeVnetAddressPrefix = '10.20.0.0/16'

// ──────────────────────────────────────────────
// Resource Groups
// ──────────────────────────────────────────────

resource rgNetworking 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefix}-networking'
  location: location
  tags: tags
}

resource rgFrontend 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefix}-frontend'
  location: location
  tags: tags
}

resource rgData 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefix}-data'
  location: location
  tags: tags
}

resource rgSecurity 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefix}-security'
  location: location
  tags: tags
}

resource rgMonitoring 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefix}-monitoring'
  location: location
  tags: tags
}

// ──────────────────────────────────────────────
// Modules
// ──────────────────────────────────────────────

// Hub VNet
module hubVnet 'modules/network/hub-vnet.bicep' = {
  name: 'deploy-hub-vnet'
  scope: rgNetworking
  params: {
    location: location
    vnetName: 'vnet-${locationCode}-hub-${environment}'
    hubVnetAddressPrefix: hubVnetAddressPrefix
    tags: tags
  }
}

// Spoke VNet
module spokeVnet 'modules/network/spoke-vnet.bicep' = {
  name: 'deploy-spoke-vnet'
  scope: rgNetworking
  params: {
    location: location
    vnetName: 'vnet-${locationCode}-spoke-${environment}'
    addressPrefix: spokeVnetAddressPrefix
    environment: environment
    tags: tags
  }
}

// Key Vault
module keyVault 'modules/security/key-vault.bicep' = {
  name: 'deploy-key-vault'
  scope: rgSecurity
  params: {
    location: location
    keyVaultName: 'kv-${appName}-${environment}'
    tags: tags
  }
}

// App Service Plan
module appServicePlan 'modules/compute/app-service-plan.bicep' = {
  name: 'deploy-app-service-plan'
  scope: rgFrontend
  params: {
    location: location
    planName: 'asp-${prefix}'
    sku: appServiceSku
    tags: tags
  }
}

// Web App
module webApp 'modules/compute/app-service.bicep' = {
  name: 'deploy-web-app'
  scope: rgFrontend
  params: {
    location: location
    appName: 'app-${prefix}-web'
    appServicePlanId: appServicePlan.outputs.planId
    keyVaultName: keyVault.outputs.keyVaultName
    vnetSubnetId: spokeVnet.outputs.webSubnetId
    environment: environment
    tags: tags
  }
}

// SQL Server
module sqlServer 'modules/data/sql-server.bicep' = {
  name: 'deploy-sql-server'
  scope: rgData
  params: {
    location: location
    serverName: 'sql-${prefix}'
    adminObjectId: '00000000-0000-0000-0000-000000000000' // TODO: vervang met echt Entra ID objectId
    tags: tags
  }
}

// SQL Database
module sqlDatabase 'modules/data/sql-database.bicep' = {
  name: 'deploy-sql-database'
  scope: rgData
  params: {
    location: location
    serverName: sqlServer.outputs.serverName
    databaseName: 'sqldb-${prefix}'
    sku: sqlSku
    maxSizeGB: sqlMaxSizeGB
    tags: tags
  }
}

// Storage Account
module storageAccount 'modules/data/storage-account.bicep' = {
  name: 'deploy-storage-account'
  scope: rgData
  params: {
    location: location
    storageAccountName: 'st${appName}${environment}'
    storageSku: storageSku
    tags: tags
  }
}

// Managed Identity (user-assigned)
module managedIdentity 'modules/security/managed-identity.bicep' = {
  name: 'deploy-managed-identity'
  scope: rgSecurity
  params: {
    location: location
    identityName: 'id-${prefix}'
    tags: tags
  }
}

// Function App
module functionApp 'modules/compute/function-app.bicep' = {
  name: 'deploy-function-app'
  scope: rgFrontend
  params: {
    location: location
    functionAppName: 'func-${prefix}'
    appServicePlanId: appServicePlan.outputs.planId
    storageAccountName: storageAccount.outputs.storageAccountName
    keyVaultName: keyVault.outputs.keyVaultName
    vnetSubnetId: spokeVnet.outputs.funcSubnetId
    tags: tags
  }
}

// Private Endpoint - SQL
module privateEndpointSql 'modules/network/private-endpoint.bicep' = {
  name: 'deploy-pe-sql'
  scope: rgNetworking
  params: {
    location: location
    privateEndpointName: 'pe-sql-${prefix}'
    serviceResourceId: sqlServer.outputs.serverId
    subnetId: spokeVnet.outputs.dataSubnetId
    groupId: 'sqlServer'
    privateDnsZoneId: privateDnsZoneSqlId
    tags: tags
  }
}

// Private Endpoint - Key Vault
module privateEndpointKv 'modules/network/private-endpoint.bicep' = {
  name: 'deploy-pe-kv'
  scope: rgNetworking
  params: {
    location: location
    privateEndpointName: 'pe-kv-${prefix}'
    serviceResourceId: keyVault.outputs.keyVaultId
    subnetId: spokeVnet.outputs.dataSubnetId
    groupId: 'vault'
    privateDnsZoneId: privateDnsZoneKvId
    tags: tags
  }
}

// Private Endpoint - Storage (Blob)
module privateEndpointStorage 'modules/network/private-endpoint.bicep' = {
  name: 'deploy-pe-storage'
  scope: rgNetworking
  params: {
    location: location
    privateEndpointName: 'pe-st-${prefix}'
    serviceResourceId: storageAccount.outputs.storageAccountId
    subnetId: spokeVnet.outputs.dataSubnetId
    groupId: 'blob'
    privateDnsZoneId: privateDnsZoneStorageBlobId
    tags: tags
  }
}

// ──────────────────────────────────────────────
// Outputs
// ──────────────────────────────────────────────

output webAppName string = webApp.outputs.appName
output sqlServerFqdn string = sqlServer.outputs.fqdn
output keyVaultUri string = keyVault.outputs.keyVaultUri
output storageAccountName string = storageAccount.outputs.storageAccountName
output functionAppName string = functionApp.outputs.functionAppName
