// main.dev.bicepparam — Development parameters
// Goedkopere SKUs, serverless SQL

using './main.bicep'

param environment = 'dev'
param location = 'westeurope'
param locationCode = 'weu'
param appName = 'contoso'

// ── Compute — lager voor dev ───────────────────────────────────────────
param appServiceSku = 'B1'

// ── Database — serverless voor dev ────────────────────────────────────
param sqlSku = 'GP_S_Gen5_2'
param sqlMaxSizeGB = 50

// ── Storage — LRS voor dev ────────────────────────────────────────────
param storageSku = 'Standard_LRS'

// ── Private DNS Zones — zelfde hub als prd ────────────────────────────
param privateDnsZoneSqlId = '/subscriptions/<subId>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net'
param privateDnsZoneKvId = '/subscriptions/<subId>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
param privateDnsZoneStorageBlobId = '/subscriptions/<subId>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'

// ── Tags ───────────────────────────────────────────────────────────────
param tags = {
  Environment: 'dev'
  Application: 'contoso-manufacturing'
  Owner: 'team-cloud@contoso.be'
  CostCenter: 'CC-IT-001'
  DataClassification: 'internal'
  ManagedBy: 'bicep'
}
