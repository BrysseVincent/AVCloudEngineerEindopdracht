// modules/security/key-vault.bicep

@description('Azure region')
param location string

@description('Key Vault name (globally unique, 3-24 chars)')
@minLength(3)
@maxLength(24)
param keyVaultName string

@description('Tags')
param tags object

@description('SKU: standard or premium (premium supports HSM)')
@allowed(['standard', 'premium'])
param sku string = 'standard'

@description('Object ID of the current deployer (for initial access)')
param deployerObjectId string = ''

// ── Key Vault ─────────────────────────────────────────────────────────

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: sku
    }
    tenantId: tenant().tenantId
    enableRbacAuthorization: true          // Gebruik RBAC, niet legacy access policies
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true            // Vereist voor CMK gebruik
    publicNetworkAccess: 'Disabled'        // Alleen via Private Endpoint
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

// ── Diagnostics ───────────────────────────────────────────────────────
// TODO: voeg Log Analytics workspace referentie toe voor audit logging

// ── Outputs ───────────────────────────────────────────────────────────

output keyVaultId string = keyVault.id
output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
