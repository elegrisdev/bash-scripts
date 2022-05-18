#!/bin/bash

## This script update cluster secret credential, cluster secret is good for one year only for security reasons
## Follow this link for more explanations : https://docs.microsoft.com/en-us/azure/aks/update-credentials#update-aks-cluster-with-new-service-principal-credentials
## Only for clusters configured with Service Principal

## How-to : ./Update-AKS-Credentials.sh SUBSCRIPTION RESOURCE_GROUP_NAME CLUSTER_NAME
## Sample command : ./Update-AKS-Credentials.sh "SUBSCRIPTION_NAME" RG_NAME AKS_NAME

# Set Variables
subscription=$1
resourcegroup=$2
clustername=$3

# Login to Azure and set the context
az login
az account set --subscription "$subscription"

# Launch cluster service principal and secret update
SP_ID=$(az aks show --resource-group $resourcegroup --name $clustername --query servicePrincipalProfile.clientId -o tsv)
SP_SECRET=$(az ad sp credential reset --name $SP_ID --query password -o tsv)

sleep 30

[ -z "$SP_SECRET" ] && echo "Secret variable is empty, cluster will not upgrade credentials." || \
    az aks update-credentials --resource-group $resourcegroup --name $clustername --reset-service-principal --service-principal "$SP_ID" --client-secret "$SP_SECRET"
