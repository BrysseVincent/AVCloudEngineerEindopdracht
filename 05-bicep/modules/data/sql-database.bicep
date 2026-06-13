// modules/data/sql-database.bicep
// Azure SQL Database voor Contoso Manufacturing
// General Purpose, 4 vCores, zone-redundant, RA-GRS backup

// ── Parameters ────────────────────────────────────────────────────────

@description('Azure region')
param location string

@description('SQL Server name (parent resource)')
param serverName string

@description('SQL Database name')
param databaseName string

@description('SKU: GP_Gen5_4 voor prd, GP_Gen5_2 voor tst, GP_S_Gen5_2 voor dev (serverless)')
@allowed(['GP_Gen5_4', 'GP_Gen5_2', 'GP_S_Gen5_2'])
param sku string = 'GP_Gen5_4'

@description('Max database size in GB')
param maxSizeGB int = 500

@description('Enable zone redundancy (prd only)')
param zoneRedundant bool = false

@description('Backup storage redundancy')
@allowed(['Local', 'Zone', 'Geo', 'GeoZone'])
param backupRedundancy string = 'Geo'

@description('Log Analytics Workspace ID for diagnostics')
param logAnalyticsWorkspaceId string = ''

@description('Tags')
param tags object

// ── Variables ─────────────────────────────────────────────────────────

var isServerless = contains(sku, '_S_')    // GP_S_ = serverless tier

// ── SQL Database ──────────────────────────────────────────────────────

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  name: '${serverName}/${databaseName}'
  location: location
  tags: tags
  sku: {
    name: sku
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: isServerless ? 2 : (sku == 'GP_Gen5_4' ? 4 : 2)
  }
  properties: {
    maxSizeBytes: maxSizeGB * 1073741824   // GB naar bytes
    zoneRedundant: zoneRedundant
    requestedBackupStorageRedundancy: backupRedundancy
    readScale: 'Disabled'
    autoPauseDelay: isServerless ? 60 : -1  // 60 min voor serverless, -1 = uitgeschakeld
    // minCapacity must be an integer per Bicep type; use 1 for serverless minimum to satisfy the type
    minCapacity: isServerless ? 1 : null
  }
}

// ── Diagnostics ───────────────────────────────────────────────────────

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: 'diag-${databaseName}'
  scope: sqlDatabase
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'SQLInsights'
        enabled: true
      }
      {
        category: 'QueryStoreRuntimeStatistics'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Basic'
        enabled: true
      }
    ]
  }
}

// ── Outputs ───────────────────────────────────────────────────────────

output databaseName string = sqlDatabase.name
output databaseId string = sqlDatabase.id
