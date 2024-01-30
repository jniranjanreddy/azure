# Change these four parameters as needed
# Source: https://learn.microsoft.com/en-us/azure/container-instances/container-instances-volume-azure-files
ACI_PERS_RESOURCE_GROUP=stage-demo-croma-instance
ACI_PERS_STORAGE_ACCOUNT_NAME=stagedemocromaaccount
ACI_PERS_LOCATION=eastus
ACI_PERS_SHARE_NAME=stage-demo-croma-share

# Create the storage account with the parameters
az storage account create --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_PERS_STORAGE_ACCOUNT_NAME --location $ACI_PERS_LOCATION --sku Standard_LRS

# Create the file share
az storage share create --name $ACI_PERS_SHARE_NAME --account-name $ACI_PERS_STORAGE_ACCOUNT_NAME

#Storage account key - This value can be found using the following command:

STORAGE_KEY=$(az storage account keys list --resource-group $ACI_PERS_RESOURCE_GROUP --account-name $ACI_PERS_STORAGE_ACCOUNT_NAME --query "[0].value" --output tsv)
echo $STORAGE_KEY


az container create --resource-group $ACI_PERS_RESOURCE_GROUP \
--name stage-demo-chroma-instance \
--image chromadbregistry.azurecr.io/data/chroma-db-image:v3  \
--dns-name-label stage-demo \
--ports 8000 --azure-file-volume-account-name $ACI_PERS_STORAGE_ACCOUNT_NAME \
--azure-file-volume-account-key $STORAGE_KEY \
--azure-file-volume-share-name $ACI_PERS_SHARE_NAME \
--azure-file-volume-mount-path /chroma/chroma