param vaultName string
param location string
param tags object
param contributorRBACObjectId string
param webAppId string
param virtualNetworkRules array
param ipRules array

resource KeyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: vaultName 
  location: location
  tags: tags
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: contributorRBACObjectId
        permissions: {
          certificates: [
            'Get'
            'List'
            'Update'
            'Create'
            'Import'
            'Delete'
            'Recover'
            'Backup'
            'Restore'
            'ManageContacts'
            'ManageIssuers'
            'GetIssuers'
            'ListIssuers'
            'SetIssuers'
            'DeleteIssuers'
          ]
          keys: [
            'Get'
            'List'
            'Update'
            'Create'
            'Import'
            'Delete'
            'Recover'
            'Backup'
            'Restore'
            'GetRotationPolicy'
            'SetRotationPolicy'
            'Rotate'
          ]
          secrets: [
            'Get'
            'List'
            'Set'
            'Delete'
            'Recover'
            'Backup'
            'Restore'
          ]
        }
      }
      {
        tenantId: subscription().tenantId
        objectId: webAppId
        permissions: {
          certificates: []
          keys: []
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enablePurgeProtection: true
    enableRbacAuthorization: false
    enableSoftDelete: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: ipRules
      virtualNetworkRules: virtualNetworkRules
    }
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
    sku: {
      family: 'A'
      name: 'standard'
    }
    softDeleteRetentionInDays: 30
    tenantId: subscription().tenantId
    vaultUri: 'https://${vaultName}${environment().suffixes.keyvaultDns}'//'https://${vaultName}.vault.azure.net/'
  }
}
