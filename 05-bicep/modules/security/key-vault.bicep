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
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

// ── RBAC Access for Deployer ──────────────────────────────────────────

resource deployerAccess 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(deployerObjectId)) {
  name: guid(keyVault.id, deployerObjectId, 'KeyVaultAccess')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'b86a8fe4-44ce-4948-aee5-eccb2c155cd7' // Key Vault Secrets Officer
    )
    principalId: deployerObjectId
  }
}

// ── Outputs ───────────────────────────────────────────────────────────

output keyVaultId string = keyVault.id
output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
