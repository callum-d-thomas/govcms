param location string
param tags object
param name string
param workspaceName string
param kind string = 'web'

resource workspaceReference 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing ={
  name: workspaceName
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: {
    Application_Type: kind
    Flow_Type: 'BlueField'
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    WorkspaceResourceId: workspaceReference.id 
  }
}

output applicationInsightsId string = applicationInsights.id
output instrumentationKey string = applicationInsights.properties.InstrumentationKey
output connectionString string = applicationInsights.properties.ConnectionString
