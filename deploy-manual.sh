#!/bin/bash

# Log in to Azure (interactive)
az login

# Create the resource group if it doesn't exist
az group create --name devops-rg --location uksouth

# Deploy ARM template with parameters
az deployment group create --resource-group devops-rg --template-file templates/storage-arm.json --parameters @templates/dev.parameters.json

# Deploy Bicep template with parameters
az deployment group create --resource-group devops-rg --template-file templates/storage-bicep.bicep --parameters @templates/dev.parameters.bicep.json
