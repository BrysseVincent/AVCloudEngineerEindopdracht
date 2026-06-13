// main.bicepparam — Productie parameters
// Pas aan naar jouw omgeving

using './main.bicep'

param environment = 'prd'
param location = 'westeurope'
param locationCode = 'weu'
param appName = 'contoso'
param privateDnsZoneSqlId = '/subscriptions/<subId>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net'
param privateDnsZoneKvId = '/subscriptions/<subId>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
param privateDnsZoneStorageBlobId = '/subscriptions/<subId>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'
param tags = {
  Environment: 'prd'
  Application: 'contoso-manufacturing'
  Owner: 'team-cloud@contoso.be'
  CostCenter: 'CC-IT-001'
  DataClassification: 'internal'
  ManagedBy: 'bicep'
}
