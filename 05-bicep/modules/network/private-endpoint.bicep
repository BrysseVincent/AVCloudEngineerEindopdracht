// modules/network/private-endpoint.bicep
// Private Endpoint voor Contoso Manufacturing
// Herbruikbaar voor SQL, Storage, Key Vault

// ── Parameters ────────────────────────────────────────────────────────

@description('Azure region')
param location string

@description('Private Endpoint name')
param privateEndpointName string

@description('Resource ID van de te beveiligen service')
param serviceResourceId string

@description('Subnet ID waar de Private Endpoint in komt')
param subnetId string

@description('Group ID van de service (bijv. sqlServer, blob, vault)')
@allowed(['sqlServer', 'blob', 'file', 'vault', 'sites'])
param groupId string

@description('Private DNS Zone ID voor koppeling')
param privateDnsZoneId string

@description('Tags')
param tags object

// ── Private Endpoint ──────────────────────────────────────────────────

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: serviceResourceId
          groupIds: [ groupId ]
        }
      }
    ]
  }
}

// ── DNS Zone Group ────────────────────────────────────────────────────

resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  name: 'default'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

// ── Outputs ───────────────────────────────────────────────────────────

output privateEndpointId string = privateEndpoint.id
output privateEndpointName string = privateEndpoint.name
