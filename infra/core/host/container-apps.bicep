metadata description = 'Creates an Azure Container Registry and an Azure Container Apps environment.'

param name string
param location string = resourceGroup().location
param tags object = {}

param containerAppsEnvironmentName string
param containerRegistryName string
param containerRegistryResourceGroupName string = ''
param containerRegistryAdminUserEnabled bool = false
param logAnalyticsWorkspaceName string
param applicationInsightsName string = ''

module containerAppsEnvironment 'container-apps-environment.bicep' = {
  name: '${name}-container-apps-environment'
  params: {
    name: containerAppsEnvironmentName
    location: location
    tags: tags
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    applicationInsightsName: applicationInsightsName
  }
}

// Only deploy this if containerRegistryResourceGroupName is empty (use current RG)
module containerRegistryDefault 'container-registry.bicep' = if (empty(containerRegistryResourceGroupName)) {
  name: '${name}-container-registry'
  scope: resourceGroup()
  params: {
    name: containerRegistryName
    location: location
    adminUserEnabled: containerRegistryAdminUserEnabled
    tags: tags
  }
}

// Only deploy this if containerRegistryResourceGroupName is provided (use provided RG)
module containerRegistryCustom 'container-registry.bicep' = if (!empty(containerRegistryResourceGroupName)) {
  name: '${name}-container-registry'
  scope: resourceGroup(containerRegistryResourceGroupName)
  params: {
    name: containerRegistryName
    location: location
    adminUserEnabled: containerRegistryAdminUserEnabled
    tags: tags
  }
}

output defaultDomain string = containerAppsEnvironment.outputs.defaultDomain
output environmentName string = containerAppsEnvironment.outputs.name
output environmentId string = containerAppsEnvironment.outputs.id

output registryLoginServer string = empty(containerRegistryResourceGroupName)
  ? containerRegistryDefault.outputs.loginServer
  : containerRegistryCustom.outputs.loginServer

output registryName string = empty(containerRegistryResourceGroupName)
  ? containerRegistryDefault.outputs.name
  : containerRegistryCustom.outputs.name
