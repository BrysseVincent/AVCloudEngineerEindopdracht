// modules/network/hub-vnet.bicep
// Hub VNet — Connectivity Subscription
// Bevat: AzureFirewallSubnet, GatewaySubnet, AzureBastionSubnet, snet-hub-dns

// ── Parameters ────────────────────────────────────────────────────────

@description('Azure region')
param location string

@description('Hub VNet name')
param vnetName string = 'vnet-hub-contoso-prd-weu'

@description('Tags')
param tags object

@description('Address prefix for the Hub VNet')
param hubVnetAddressPrefix string = '10.0.0.0/16'

// ── Hub VNet ──────────────────────────────────────────────────────────

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [hubVnetAddressPrefix]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.0.0/26'
        }
      }
      {
        name: 'AzureFirewallManagementSubnet'
        properties: {
          addressPrefix: '10.0.0.64/26'
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.1.0/27'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.2.0/27'
        }
      }
      {
        name: 'snet-hub-dns'
        properties: {
          addressPrefix: '10.0.3.0/28'
          delegations: [
            {
              name: 'dnsDelegation'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
        }
      }
    ]
  }
}

// ── Outputs ───────────────────────────────────────────────────────────

output vnetId string = hubVnet.id
output vnetName string = hubVnet.name
output firewallSubnetId string = hubVnet.properties.subnets[0].id
output gatewaySubnetId string = hubVnet.properties.subnets[2].id
output bastionSubnetId string = hubVnet.properties.subnets[3].id
output dnsSubnetId string = hubVnet.properties.subnets[4].id
