// modules/data/storage-account.bicep
// Storage Account voor Contoso Manufacturing
// Vervangt on-premises NAS shares (UNC)

// ── Parameters ────────────────────────────────────────────────────────

@description('Azure region')
param location string

@description('Storage Account name (lowercase, no hyphens, max 24 chars)')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Storage SKU: Standard_GRS voor prd, Standard_LRS voor dev/tst')
@allowed(['Standard_GRS', 'Standard_LRS', 'Standard_ZRS'])
param storageSku string = 'Standard_GRS'

@description('Log Analytics Workspace ID for diagnostics')
param logAnalyticsWorkspaceId string = ''

@description('Tags')
param tags object

// ── Storage Account ───────────────────────────────────────────────────

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: storageSku
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'           // Azure Policy vereiste
    allowBlobPublicAccess: false           // Geen publieke blob toegang
    publicNetworkAccess: 'Disabled'        // Enkel via Private Endpoint
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

// ── Blob Service ──────────────────────────────────────────────────────

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 30                             // Soft delete 30 dagen
    }
  }
}

// ── File Service ──────────────────────────────────────────────────────

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 30
    }
  }
}

// ── Diagnostics ───────────────────────────────────────────────────────

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: 'diag-${storageAccountName}'
  scope: storageAccount
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

// ── Outputs ───────────────────────────────────────────────────────────

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
output fileEndpoint string = storageAccount.properties.primaryEndpoints.file
