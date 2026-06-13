// modules/security/managed-identity.bicep
// User Assigned Managed Identity voor Contoso Manufacturing
// Optioneel — App Services gebruiken System Assigned Managed Identity

// ── Parameters ────────────────────────────────────────────────────────

@description('Azure region')
param location string

@description('Managed Identity name')
param identityName string

@description('Tags')
param tags object

// ── Managed Identity ──────────────────────────────────────────────────

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
  tags: tags
}

// ── Outputs ───────────────────────────────────────────────────────────

output identityId string = managedIdentity.id
output identityName string = managedIdentity.name
output principalId string = managedIdentity.properties.principalId
output clientId string = managedIdentity.properties.clientId
