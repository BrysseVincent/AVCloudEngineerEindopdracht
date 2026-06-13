@description('Azure region')
param location string

@description('VNet name')
param vnetName string

@description('VNet address prefix')
param addressPrefix string

@description('Tags')
param tags object

@description('Environment: dev, tst, prd')
@allowed(['dev', 'tst', 'prd'])
param environment string

// ── Subnets ──────────────────────────────────────────────────────────

var subnets = [
  {
    name: 'snet-appgw'
    cidr: '10.20.0.0/24'
    type: 'appgw'
    delegations: []
  }
  {
    name: 'snet-data'
    cidr: '10.20.3.0/28'
    type: 'data'
    delegations: []
  }
  {
    name: 'snet-func'
    cidr: '10.20.2.0/27'
    type: 'func'
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
    name: 'snet-mgmt'
    cidr: '10.20.4.0/28'
    type: 'mgmt'
    delegations: []
  }  
  {
    name: 'snet-web'
    cidr: '10.20.1.0/27'
    type: 'web'
    delegations: [
      {
        name: 'delegation-appservice'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
]

// ── NSG’s per subnet ─────────────────────────────────────────────────

module nsgs 'nsg.bicep' = [for subnet in subnets: {
  name: 'nsg-${subnet.name}-${environment}'
  params: {
    location: location
    nsgName: 'nsg-${subnet.name}-${environment}'
    subnetType: subnet.type
    tags: tags
  }
}]

// ── Virtual Network ───────────────────────────────────────────────────

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [ addressPrefix ]
    }
    subnets: [for (subnet, i) in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.cidr
        delegations: subnet.delegations
        networkSecurityGroup: {
          id: nsgs[i].outputs.nsgId
        }
        privateEndpointNetworkPolicies: 'Disabled'
      }
    }]
  }
}

// ── Outputs ───────────────────────────────────────────────────────────

output vnetId string = vnet.id
output vnetName string = vnet.name
output webSubnetId string = vnet.properties.subnets[4].id
output dataSubnetId string = vnet.properties.subnets[1].id
output funcSubnetId string = vnet.properties.subnets[2].id
