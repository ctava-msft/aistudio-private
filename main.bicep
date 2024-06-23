// Parameters
@minLength(2)
@maxLength(14)
@description('Name for the AI resource and used to derive name of dependent resources.')
param aiHubName string = 'AI Hub Name'

@description('Friendly name for your Azure AI resource')
param aiHubFriendlyName string = 'AI Hub Friendly Name'

@description('Description of your Azure AI resource dispayed in AI studio')
param aiHubDescription string = 'AI Hub Description'

@description('ComputeNode Admin User Name')
param computeNodeAdminUserName string
@minLength(4)
@secure()
@description('ComputeNode Admin User Password')
param computeNodeAdminPassword string

@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object = {}

// Variables
var name = toLower('${aiHubName}')

// Create a short, unique suffix, that will be unique to each resource group
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 4)

// Dependent resources for the Azure Machine Learning workspace
module aiDependencies 'modules/dependent-resources.bicep' = {
  name: 'dependencies-${name}-${uniqueSuffix}-deployment'
  params: {
    aiServicesName: 'ai-${name}${uniqueSuffix}'
    computeNodeAdminUserName: computeNodeAdminUserName
    computeNodeAdminPassword: computeNodeAdminPassword
    location: location
    storageName: 'st-${name}${uniqueSuffix}'
    keyvaultName: 'kv-${name}-${uniqueSuffix}'
    tags: tags
  }
}

// AIStudioHub Resource
module aiHub 'modules/aistudio-hub.bicep' = {
  name: '${name}-${uniqueSuffix}-deployment'
  params: {
    // workspace setup
    aiHubName: '${name}-${uniqueSuffix}'
    aiHubFriendlyName: aiHubFriendlyName
    aiHubDescription: aiHubDescription
    location: location
    tags: tags

    // dependent resources
    aiServicesId: aiDependencies.outputs.aiservicesID
    aiServicesTarget: aiDependencies.outputs.aiservicesTarget
    computeNodeId: aiDependencies.outputs.computeNodeId
    keyVaultId: aiDependencies.outputs.keyvaultId
    storageAccountId: aiDependencies.outputs.storageId
  }
}
