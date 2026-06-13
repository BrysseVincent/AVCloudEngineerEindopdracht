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

// ── Hub VNet ──────────────────────────────────────────────────────────

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        // Vereiste exacte naam voor Azure Firewall
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.0.0/26'
        }
      }
      {
        // Vereiste exacte naam voor Firewall management
        name: 'AzureFirewallManagementSubnet'
        properties: {
          addressPrefix: '10.0.0.64/26'
        }
      }
      {
        // Vereiste exacte naam voor VPN/ExpressRoute Gateway
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.1.0/27'
        }
      }
      {
        // Vereiste exacte naam voor Azure Bastion
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.2.0/27'
        }
      }
      {
        // DNS Private Resolver subnet
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
