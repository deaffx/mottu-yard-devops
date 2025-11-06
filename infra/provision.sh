#!/bin/bash
set -e

ACR_NAME="mottuyardacr$RANDOM"
RG_NAME="rg-mottu-yard"
LOCATION="brazilsouth"
DB_SERVER="mottuyarddb$RANDOM"
DB_NAME="challenge"
DB_USER="mottuadmin"
DB_PASSWORD="Mottu@2024#Secure"
ACI_NAME="mottu-yard-aci"

echo "=== Criando Resource Group ==="
az group create --name $RG_NAME --location $LOCATION

echo "=== Criando Azure Container Registry ==="
az acr create --resource-group $RG_NAME --name $ACR_NAME --sku Basic --location $LOCATION

echo "=== Habilitando admin user no ACR ==="
az acr update --name $ACR_NAME --admin-enabled true

echo "=== Criando PostgreSQL Flexible Server ==="
az postgres flexible-server create \
  --resource-group $RG_NAME \
  --name $DB_SERVER \
  --location $LOCATION \
  --admin-user $DB_USER \
  --admin-password "$DB_PASSWORD" \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --storage-size 32 \
  --version 16 \
  --public-access 0.0.0.0-255.255.255.255 \
  --yes \
  --output none

echo "=== Criando banco de dados ==="
az postgres flexible-server db create \
  --resource-group $RG_NAME \
  --server-name $DB_SERVER \
  --database-name $DB_NAME \
  --output none

ACR_USERNAME=$(az acr credential show -n "$ACR_NAME" --query username -o tsv)
ACR_PASSWORD=$(az acr credential show -n "$ACR_NAME" --query "passwords[0].value" -o tsv)
ACR_LOGIN_SERVER="${ACR_NAME}.azurecr.io"
DB_FQDN="${DB_SERVER}.postgres.database.azure.com"

echo ""
echo "✅ Provisionamento concluído!"
echo ""
echo "Configure as variáveis no Azure DevOps Pipeline:"
echo ""
echo "ACR_NAME=$ACR_NAME"
echo "ACR_LOGIN_SERVER=$ACR_LOGIN_SERVER"
echo "ACR_USERNAME=$ACR_USERNAME (secret)"
echo "ACR_PASSWORD=$ACR_PASSWORD (secret)"
echo "RESOURCE_GROUP=$RG_NAME"
echo "ACI_NAME=$ACI_NAME"
echo "DB_SERVER=$DB_FQDN"
echo "DB_NAME=$DB_NAME"
echo "DB_USER=$DB_USER (secret)"
echo "DB_PASS=$DB_PASSWORD (secret)"
echo ""
echo "Configure também estas variáveis (marque como secret):"
echo "GITHUB_CLIENT_ID=seu-valor-aqui (secret)"
echo "GITHUB_CLIENT_SECRET=seu-valor-aqui (secret)"
echo ""
echo "Depois execute a pipeline para deploy"
