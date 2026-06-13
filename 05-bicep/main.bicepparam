// main.bicepparam — Productie parameters
// Pas <subId> en <rg> aan naar jouw omgeving na hub deployment

using './main.bicep'

param environment = 'prd'
param location = 'westeurope'
param locationCode = 'weu'
param appName = 'contoso'

// ── Compute ────────────────────────────────────────────────────────────
param appServiceSku = 'P2v3'

// ── Database ───────────────────────────────────────────────────────────
param sqlSku = 'GP_Gen5_4'
param sqlMaxSizeGB = 500

// ── Storage ────────────────────────────────────────────────────────────
param storageSku = 'Standard_GRS'

// ── Private DNS Zones — vervang na hub deployment ──────────────────────
param privateDnsZoneSqlId = '/subscriptions/<subId>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net'
param privateDnsZoneKvId = '/subscriptions/<subId>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
param privateDnsZoneStorageBlobId = '/subscriptions/<subId>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'

// ── Tags ───────────────────────────────────────────────────────────────
param tags = {
  Environment: 'prd'
  Application: 'contoso-manufacturing'
  Owner: 'team-cloud@contoso.be'
  CostCenter: 'CC-IT-001'
  DataClassification: 'internal'
  ManagedBy: 'bicep'
}
