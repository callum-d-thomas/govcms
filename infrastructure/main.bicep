param location string
param namingLocation string
param environmentName string
param resourceTags object
param environmentIdentifier string
param contributorRBACObjectId string
param networkResourceGroup string
param virtualNetworkRules array
param ipRules array

param appServicePlanName string = 'dojwa-plan-${namingLocation}-internal-${environmentName}-${environmentIdentifier}'
param appServicePlanResourceGroup string = 'rg-kit-asplan-${environmentName}-${environmentIdentifier}'

param appDeploymentVirtualNetworkName string = 'vnet-${namingLocation}-hub-${environmentName}-01'
param internalServerFarmsSubnetName string

param buildAgentSubscriptionId string
param buildAgentResourceGroup string
param buildAgentVirtualNetwork string
param buildAgentSubnet string

param networkSubscription string
param appGatewayResourceGroup string
param appGatewayVirtualNetwork string
param appGatewaySubnet string = 'snet-aue-hub-${environmentName}appgateway-nwk'

param webAppName string = 'dojwa-app-cts-public-websites-${environmentName}'
param keyVaultName string = 'dojkvctspublicsiteapp${environmentName}'

param workspaceName string = 'dojwa-workspaces-${namingLocation}-cts-public-websites-${environmentName}-${environmentIdentifier}'
param logAnalyticsSku string = 'PerGB2018'
param logAnalyticsRetentionInDays int = 90

// param Authentication object
// var AuthenticationVar = {
//   enabled: Authentication.Enabled
//   configFileLocation: Authentication.ConfigFileLocation
//   clientSecretKeyVaultUri: '@Microsoft.KeyVault(SecretUri=https://${KeyVaultName}${environment().suffixes.keyvaultDns}/secrets/${Authentication.FinanceApiClientSecretKeyVaultSecretName}/)'
// }


var keyVaultIPRulesVar = [for item in ipRules: {
  value: '${item.IP}/${item.Mask}'
}]

var storageAccountIPRulesVar = [for item in ipRules: {
  value: item.IP
  action: 'Allow'
}]

var virtualNetworkRulesVar = [for item in virtualNetworkRules: {
  id: resourceId(networkResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', item.VirtualNetworkName, item.SubnetName)
  ignoreMissingVnetServiceEndpoint: false
}]


module workspace 'modules/workspace.bicep' = {
  name: 'deployWorkspace'
  params: {
    location: location
    tags: resourceTags
    name: workspaceName
    retentionInDays: logAnalyticsRetentionInDays
    sku: logAnalyticsSku
  }
}

module storageAccount 'modules/storageAccount.bicep' = {
  name: 'deployStorageAccount'
  params: {
    location: location
    tags: resourceTags
    environmentName: environmentName
    ipRules: storageAccountIPRulesVar
    virtualNetworkRules : virtualNetworkRulesVar
  }
}

module appInsights 'modules/appInsights.bicep' = {
  name: 'deployApplicationInsights'
  params: {
    location: location
    tags: resourceTags
    name: webAppName
    workspaceName: workspaceName
  }
  dependsOn: [
    workspace
  ]
}

module webApp 'modules/webApp.bicep' = {
  name: 'deployWebApp'
  params: {
    location: location
    tags: resourceTags
    webAppName: webAppName
    appServicePlanSubnetId: resourceId(appServicePlanResourceGroup, 'Microsoft.Web/serverfarms', appServicePlanName)
    buildAgentSubnetId: resourceId(buildAgentSubscriptionId, buildAgentResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', buildAgentVirtualNetwork, buildAgentSubnet) 
    appGatewaySubnetId: resourceId(networkSubscription, appGatewayResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', appGatewayVirtualNetwork, appGatewaySubnet)
    appDeploymentSubnetId: resourceId(networkResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', appDeploymentVirtualNetworkName, internalServerFarmsSubnetName)
    environmentName: environmentName
    // authentication: AuthenticationVar
  }
  dependsOn: [
    appInsights
  ]
}

module keyVault 'modules/keyVault.bicep' ={
  name: 'deployKeyVault'
  params: {
    vaultName: keyVaultName
    location: location
    tags: resourceTags
    contributorRBACObjectId: contributorRBACObjectId
    webAppId: webApp.outputs.principalId
    ipRules: keyVaultIPRulesVar
    virtualNetworkRules : virtualNetworkRulesVar
  }
}
