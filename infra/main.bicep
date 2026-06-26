@description('Prefijo único por participante (tus iniciales, ej: arb). Solo letras minúsculas.')
@minLength(2)
@maxLength(6)
param participantPrefix string

@description('Región de Azure donde se despliegan todos los recursos.')
param location string = 'eastus'

var prefix = 'workshop-${participantPrefix}'
var acrName = 'acrworkshop${participantPrefix}'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'law-${prefix}'
  location: location
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${prefix}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    RetentionInDays: 30
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: { name: 'Basic' }
  properties: { adminUserEnabled: false }
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-${prefix}'
  location: location
}

var acrPullRoleId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
resource acrPullAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, managedIdentity.id, acrPullRoleId)
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleId)
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource containerAppsEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: 'cae-${prefix}'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

resource catalogApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'ca-catalog-${participantPrefix}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: { '${managedIdentity.id}': {} }
  }
  properties: {
    environmentId: containerAppsEnv.id
    configuration: {
      ingress: { external: true, targetPort: 8080, transport: 'auto' }
      registries: [{ server: acr.properties.loginServer, identity: managedIdentity.id }]
    }
    template: {
      containers: [{
        name: 'catalog-service'
        image: 'mcr.microsoft.com/dotnet/samples:aspnetapp'
        resources: { cpu: json('0.5'), memory: '1Gi' }
        env: [
          { name: 'ASPNETCORE_ENVIRONMENT', value: 'Production' }
          { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', value: appInsights.properties.ConnectionString }
        ]
        probes: [{
          type: 'Liveness'
          httpGet: { path: '/health', port: 8080 }
          initialDelaySeconds: 15
          periodSeconds: 30
        }]
      }]
      scale: { minReplicas: 0, maxReplicas: 3 }
    }
  }
  dependsOn: [acrPullAssignment]
}

resource petclinicApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'ca-petclinic-${participantPrefix}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: { '${managedIdentity.id}': {} }
  }
  properties: {
    environmentId: containerAppsEnv.id
    configuration: {
      ingress: { external: true, targetPort: 8080, transport: 'auto' }
      registries: [{ server: acr.properties.loginServer, identity: managedIdentity.id }]
    }
    template: {
      containers: [{
        name: 'petclinic'
        image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
        resources: { cpu: json('0.5'), memory: '1Gi' }
        env: [
          { name: 'SPRING_PROFILES_ACTIVE', value: 'prod' }
          { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', value: appInsights.properties.ConnectionString }
        ]
      }]
      scale: { minReplicas: 0, maxReplicas: 3 }
    }
  }
  dependsOn: [acrPullAssignment]
}

@description('Login server del Azure Container Registry.')
output acrLoginServer string = acr.properties.loginServer

@description('Nombre del Azure Container Registry.')
output acrName string = acr.name

@description('URL pública de la app .NET (catalog-service).')
output catalogAppUrl string = 'https://${catalogApp.properties.configuration.ingress.fqdn}'

@description('URL pública de la app Java (petclinic).')
output petclinicAppUrl string = 'https://${petclinicApp.properties.configuration.ingress.fqdn}'

@description('Connection string de Application Insights.')
output appInsightsConnectionString string = appInsights.properties.ConnectionString
