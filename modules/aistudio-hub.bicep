@description('AI Hub Name')
param aiHubName string

@description('AI hub display name')
param aiHubFriendlyName string = aiHubName

@description('AI hub description')
param aiHubDescription string

@description('Resource ID of the AI Services resource')
param aiServicesId string

@description('Resource ID of the AI Services endpoint')
param aiServicesTarget string

@description('Resource ID of the Compute Node resource for the AI hub')
param computeNodeId string

@description('Resource ID of the key vault resource for storing connection strings')
param keyVaultId string

@description('Resource ID of the storage account resource for storing experimentation outputs')
param storageAccountId string

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2023-10-01' = {
  name: aiHubName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // setup
    friendlyName: aiHubFriendlyName
    description: aiHubDescription

    // dependent resources
    keyVault: keyVaultId
    storageAccount: storageAccountId

    // Disable public access
    publicNetworkAccess: 'Disabled'
  }
  kind: 'hub'

  // resource aiServicesConnection 'connections@2024-01-01-Preview' = {
  //   name: '${aiHubName}-connection'
  //   properties: {
  //     category: 'AzureOpenAI'
  //     target: aiServicesTarget
  //     authType: 'ApiKey'
  //     isSharedToAll: true
  //     credentials: {
  //       key: '${listKeys(aiServicesId, '2021-10-01').key1}'
  //     }
  //     metadata: {
  //       ApiType: 'Azure'
  //       ResourceId: aiServicesId
  //     }
  //   }
  // }
}

output aiHubID string = aiHub.id
