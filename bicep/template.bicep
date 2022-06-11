param location string = resourceGroup().location
param name string = 'zrhaptazfunc'

resource apiStorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: '${name}stor'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}


resource apiHostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: '${name}plan'
  location: location
  sku: {
    name: 'Y1'
    tier: 'dynamic'
  } 
}

resource apiInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: '${name}insights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource apiFunction 'Microsoft.Web/sites@2021-03-01' = {
  name: name
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: apiHostingPlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsDashboard'
          value: 'DefaultEndpointsProtocol=https;AccountName=${apiStorage.name};AccountKey=${listKeys(apiStorage.id, '2019-06-01').keys[0].value}'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${apiStorage.name};AccountKey=${listKeys(apiStorage.id, '2019-06-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${apiStorage.name};AccountKey=${listKeys(apiStorage.id, '2019-06-01').keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(apiInsights.id, '2015-05-01').InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        // set Node.JS Version
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~16'
        }
      ]
    }
  }
}
