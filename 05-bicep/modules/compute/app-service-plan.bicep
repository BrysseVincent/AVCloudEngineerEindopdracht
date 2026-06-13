// modules/compute/app-service-plan.bicep
// App Service Plan voor Contoso Manufacturing

// ── Parameters ────────────────────────────────────────────────────────

@description('Azure region')
param location string

@description('App Service Plan name')
param planName string

@description('SKU name: P2v3 voor prd, S2 voor tst, B1 voor dev')
@allowed(['P2v3', 'P3v3', 'S2', 'S3', 'B1', 'B2', 'B3'])
param sku string = 'P2v3'

@description('Number of instances (workers)')
@minValue(1)
@maxValue(10)
param capacity int = 2

@description('Enable zone redundancy (prd only)')
param zoneRedundant bool = false

@description('Tags')
param tags object

// ── App Service Plan ──────────────────────────────────────────────────

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: planName
  location: location
  tags: tags
  kind: 'windows'
  sku: {
    name: sku
    capacity: capacity
  }
  properties: {
    reserved: false                        // Windows
    zoneRedundant: zoneRedundant
  }
}

// ── Outputs ───────────────────────────────────────────────────────────

output planId string = appServicePlan.id
output planName string = appServicePlan.name
