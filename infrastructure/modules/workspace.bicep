param name string
param location string
param tags object
param sku string
param retentionInDays int

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  location: location
  name: name
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
  }
}

output workspaceId string = workspace.id
