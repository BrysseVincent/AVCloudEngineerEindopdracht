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

module spokeVnet 'modules/network/spoke-vnet.bicep' = {
  name: 'deploy-spoke-vnet'
  scope: rgNetworking
  params: {
    location: location
    vnetName: 'vnet-${locationCode}-spoke-${environment}'
    addressPrefix: spokeVnetAddressPrefix
    tags: tags
  }
}

module keyVault 'modules/security/key-vault.bicep' = {
  name: 'deploy-key-vault'
  scope: rgSecurity
  params: {
    location: location
    keyVaultName: 'kv-${appName}-${environment}'
    tags: tags
  }
}

module appServicePlan 'modules/compute/app-service-plan.bicep' = {
  name: 'deploy-app-service-plan'
  scope: rgFrontend
  params: {
    location: location
    planName: 'asp-${prefix}'
    sku: environment == 'prd' ? 'P2v3' : 'B2'
    tags: tags
  }
}

module webApp 'modules/compute/app-service.bicep' = {
  name: 'deploy-web-app'
  scope: rgFrontend
  params: {
    location: location
    appName: 'app-${prefix}-web'
    appServicePlanId: appServicePlan.outputs.planId
    keyVaultName: keyVault.outputs.keyVaultName
    vnetSubnetId: spokeVnet.outputs.webSubnetId
    tags: tags
  }
}

module sqlServer 'modules/data/sql-server.bicep' = {
  name: 'deploy-sql-server'
  scope: rgData
  params: {
    location: location
    serverName: 'sql-${prefix}'
    tags: tags
  }
}

module sqlDatabase 'modules/data/sql-database.bicep' = {
  name: 'deploy-sql-database'
  scope: rgData
  params: {
    location: location
    serverName: sqlServer.outputs.serverName
    databaseName: 'sqldb-${prefix}'
    sku: environment == 'prd' ? 'BC_Gen5_4' : 'GP_Gen5_2'
    tags: tags
  }
}

// ──────────────────────────────────────────────
// Outputs
// ──────────────────────────────────────────────

output webAppName string = webApp.outputs.appName
output sqlServerFqdn string = sqlServer.outputs.fqdn
output keyVaultUri string = keyVault.outputs.keyVaultUri
