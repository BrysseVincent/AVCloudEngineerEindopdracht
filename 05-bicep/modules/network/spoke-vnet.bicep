// modules/network/spoke-vnet.bicep

@description('Azure region')
param location string

@description('VNet name')
param vnetName string

@description('VNet address prefix')
param addressPrefix string

@description('Tags')
param tags object

// ── Subnets ──────────────────────────────────────────────────────────

var subnets = [
  {
    name: 'snet-appgw'
    addressPrefix: '10.20.0.0/24'
    delegations: []
  }
  {
    name: 'snet-web'
    addressPrefix: '10.20.1.0/27'
    delegations: [
      {
        name: 'delegation-appservice'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
  {
    name: 'snet-func'
    addressPrefix: '10.20.2.0/27'
    delegations: [
      {
        name: 'delegation-functions'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
  {
    name: 'snet-data'
    addressPrefix: '10.20.3.0/28'
    delegations: []
  }
  {
    name: 'snet-mgmt'
    addressPrefix: '10.20.4.0/28'
    delegations: []
  }
]

// ── NSG ──────────────────────────────────────────────────────────────

resource nsgWeb 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-snet-web'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-AppGW-Inbound'
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: cidrSubnet(addressPrefix, 24, 0)
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'Deny-All-Inbound'
        properties: {
          priority: 4096
          protocol: '*'
          access: 'Deny'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

// ── Virtual Network ───────────────────────────────────────────────────

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [ addressPrefix ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        delegations: subnet.delegations
        networkSecurityGroup: subnet.name == 'snet-web' ? {
          id: nsgWeb.id
        } : null
        privateEndpointNetworkPolicies: 'Disabled'
      }
    }]
  }
}

// ── Outputs ───────────────────────────────────────────────────────────

output vnetId string = vnet.id
output vnetName string = vnet.name
output webSubnetId string = vnet.properties.subnets[1].id
output dataSubnetId string = vnet.properties.subnets[3].id
