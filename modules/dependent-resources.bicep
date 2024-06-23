// Parameters
@description('ComputeNode Admin User Name')
param computeNodeAdminUserName string
@minLength(4)
@secure()
@description('ComputeNode Admin User Password')
param computeNodeAdminPassword string

@description('Compute Node VM Size')
param computeNodeVMSize string

@description('AI services name')
param aiServicesName string

@description('The name of the Key Vault')
param keyvaultName string

@description('Azure region of the deployment')
param location string = resourceGroup().location

@description('Name of the storage account')
param storageName string

@allowed([
  'Standard_LRS'
])
@description('Storage SKU')
param storageSkuName string = 'Standard_LRS'

//storage account name should not have any hyphen
var storageNameCleaned = replace(storageName, '-', '')

@description('Unique Suffix for Resources.')
param uniqueSuffix string = '001'

@description('Tags to add to the resources')
param tags object = {
  environment: 'development'
  project: 'aistudio_privateendpoints'
}

// Resources
resource aiServices 'Microsoft.CognitiveServices/accounts@2021-10-01' = {
  name: aiServicesName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'AIServices' // or 'OpenAI'
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
  }
}

resource computeNode 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'computeNode-${uniqueSuffix}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: computeNodeVMSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', 'ni-${uniqueSuffix}')
        }
      ]
    }
    osProfile: {
      computerName: 'computeNode'
      adminUsername: computeNodeAdminUserName
      adminPassword: computeNodeAdminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
  }
  tags: tags
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyvaultName
  location: location
  tags: tags
  properties: {
    createMode: 'default'
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    enableRbacAuthorization: true
    enablePurgeProtection: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    sku: {
      family: 'A'
      name: 'standard'
    }
    softDeleteRetentionInDays: 7
    tenantId: subscription().tenantId
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageNameCleaned
  location: location
  tags: tags
  sku: {
    name: storageSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowSharedKeyAccess: true
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: false
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Service'
        }
        table: {
          enabled: true
          keyType: 'Service'
        }
      }
    }
    isHnsEnabled: false
    isNfsV3Enabled: false
    keyPolicy: {
      keyExpirationPeriodInDays: 7
    }
    largeFileSharesState: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
  }
}

output aiservicesID string = aiServices.id
output aiservicesTarget string = aiServices.properties.endpoint
output computeNodeId string = computeNode.id
output storageId string = storage.id
output keyvaultId string = keyVault.id
