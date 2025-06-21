#!/bin/bash
az login
az group create --name demo-rg --location westeurope
az deployment group create --resource-group demo-rg --template-file templates/storage-arm.json
