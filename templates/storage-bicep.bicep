param secondStorageAccountName string

resource stg 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: secondStorageAccountName
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}
