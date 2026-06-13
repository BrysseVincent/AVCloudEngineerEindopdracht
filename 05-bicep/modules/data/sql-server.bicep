// modules/data/sql-server.bicep
// Azure SQL Server voor Contoso Manufacturing
// Inclusief: Entra ID authenticatie, Public Network Access disabled, TDE

// ── Parameters ────────────────────────────────────────────────────────

@description('Azure region')
param location string

@description('SQL Server name (globally unique)')
@minLength(1)
@maxLength(63)
param serverName string

@description('Entra ID admin display name')
param adminLogin string = 'contoso-sql-admins'

@description('Entra ID admin object ID (group or user)')
param adminObjectId string

@description('Entra ID tenant ID')
param tenantId string = tenant().tenantId

@description('Log Analytics Workspace ID for diagnostics')
param logAnalyticsWorkspaceId string = ''

@description('Tags')
param tags object

// ── SQL Server ────────────────────────────────────────────────────────

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: serverName
  location: location
  tags: tags
  properties: {
    administratorLogin: null               // Geen SQL authenticatie als primary
    publicNetworkAccess: 'Disabled'        // Enkel via Private Endpoint
    minimalTlsVersion: '1.2'
    administrators: {
      administratorType: 'ActiveDirectory'
      login: adminLogin
      sid: adminObjectId
      tenantId: tenantId
      azureADOnlyAuthentication: true      // Enkel Entra ID — geen SQL logins
    }
  }
}

// ── Transparent Data Encryption ───────────────────────────────────────

resource tde 'Microsoft.Sql/servers/encryptionProtector@2023-05-01-preview' = {
  name: 'current'
  parent: sqlServer
  properties: {
    serverKeyType: 'ServiceManaged'        // Service Managed Key (vereenvoudigd)
    autoRotationEnabled: false
  }
}

// ── Diagnostics ───────────────────────────────────────────────────────

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: 'diag-${serverName}'
  scope: sqlServer
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'SQLSecurityAuditEvents'
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

output serverName string = sqlServer.name
output serverId string = sqlServer.id
output fqdn string = sqlServer.properties.fullyQualifiedDomainName
