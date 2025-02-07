param tags object
param location string
param webAppName string
param appServicePlanSubnetId string
param buildAgentSubnetId string
param appDeploymentSubnetId string
param appGatewaySubnetId string
param environmentName string
// param authentication object

var aspNetCoreEnvironment = environmentName == 'dev' ? 'Development'
  : environmentName == 'tst' ? 'Test'
  : environmentName == 'prd' ? 'Production'
  : 'Development'

resource AppInsightsReference 'Microsoft.Insights/components@2020-02-02' existing = {
  name: webAppName
}

resource AppService 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  tags: tags
  kind: 'api'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${webAppName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${webAppName}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: appServicePlanSubnetId
    reserved: false
    isXenon: false
    hyperV: false
    dnsConfiguration: {}
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: true
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: true
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    vnetBackupRestoreEnabled: false
    customDomainVerificationId: 'EE87DC755886EDE1CEF1B543A11C7D360F051786287728263E9BED2C32273994'
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    publicNetworkAccess: 'Enabled'
    storageAccountRequired: false
    virtualNetworkSubnetId: appDeploymentSubnetId
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource AppService_WebConfig 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: AppService
  name: 'web'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v6.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: webAppName
    scmType: 'None'
    use32BitWorkerProcess: false
    webSocketsEnabled: false
    alwaysOn: true
    managedPipelineMode: 'Integrated'
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    publicNetworkAccess: 'Enabled'
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        vnetSubnetResourceId: appGatewaySubnetId
        action: 'Allow'
        tag: 'Default'
        priority: 100
        name: 'App Gateway'
      }
      {
        ipAddress: '124.254.117.14/32'
        action: 'Allow'
        tag: 'Default'
        priority: 100
        name: 'MonkeyAp'
      }
      {
        ipAddress: '167.30.222.48/28'
        action: 'Allow'
        tag: 'Default'
        priority: 100
        name: 'OnPrem'
      }
      {
        ipAddress: '20.248.234.203/32'
        action: 'Allow'
        tag: 'Default'
        priority: 100
        name: 'apim-allow'
      }
      {
        vnetSubnetResourceId: buildAgentSubnetId
        action: 'Allow'
        tag: 'Default'
        priority: 99
        name: 'Deployment'
      }
      {
        ipAddress: 'Any'
        action: 'Deny'
        priority: 2147483647
        name: 'Deny all'
        description: 'Deny all access'
      }
    ]
    ipSecurityRestrictionsDefaultAction: 'Deny'
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsDefaultAction: 'Deny'
    scmIpSecurityRestrictionsUseMain: true
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'Disabled'
    preWarmedInstanceCount: 0
    elasticWebAppScaleLimit: 0
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
  }
}

resource AppService_AppSettings 'Microsoft.Web/sites/config@2022-09-01' ={
  parent: AppService
  name:'appsettings'
  properties: {
    ASPNETCORE_ENVIRONMENT: aspNetCoreEnvironment
    APPINSIGHTS_INSTRUMENTATIONKEY: reference('Microsoft.Insights/components/${webAppName}', AppInsightsReference.apiVersion).InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: reference('Microsoft.Insights/components/${webAppName}', AppInsightsReference.apiVersion).ConnectionString
    APPINSIGHTS_PROFILERFEATURE_VERSION: '1.0.0'
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION: '1.0.0'
    ApplicationInsightsAgent_EXTENSION_VERSION: '~2'
    DiagnosticServices_EXTENSION_VERSION: '~3'
    InstrumentationEngine_EXTENSION_VERSION: 'disabled'
    SnapshotDebugger_EXTENSION_VERSION: 'disabled'
    XDT_MicrosoftApplicationInsights_BaseExtensions: 'disabled'
    XDT_MicrosoftApplicationInsights_Mode: 'recommended'
    XDT_MicrosoftApplicationInsights_PreemptSdk: '1'
    XDT_MicrosoftApplicationInsights_NodeJS: '1'
    XDT_MicrosoftApplicationInsights_Java: '1'
    // MICROSOFT_PROVIDER_AUTHENTICATION_SECRET: authentication.clientSecretKeyVaultUri
  }
  dependsOn: [AppInsightsReference]
}

// resource AppService_AuthSettings 'Microsoft.Web/sites/config@2022-09-01' = {
//   parent: AppService
//   name: 'authsettingsV2'
//   dependsOn: [
//     AppService_AppSettings
//   ]
//   properties: {
//     platform: {
//       enabled: authentication.enabled
//       configFilePath: authentication.configFileLocation
//     }
//   }
// }

output principalId string = AppService.identity.principalId
