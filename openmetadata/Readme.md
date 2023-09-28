## Source: https://docs.open-metadata.org/v1.0.0/deployment/kubernetes/onprem
## Source: https://github.com/open-metadata/OpenMetadata
## Source: https://www.syntio.net/en/labs-musings/deploying-openmetadata-on-azure-kubernetes-service/
## data-ingestion: https://www.youtube.com/watch?v=rB77sPtPtJ4
## Create AKS for OpenMetadata
```
 az aks create --name aks-1-22 \
  --resource-group  aks-1-22 \
  --location  westeurope \
  --node-count 3 \
  --node-vm-size Standard_B2ms \
  --node-zones 1 2 3 \
  --aks-custom-headers EnableAzureDiskFileCSIDriver=true
```
## Update existing Cluster
```
az aks update -n myAKSCluster -g myResourceGroup --enable-disk-driver --enable-file-driver
```
![image](https://github.com/jniranjanreddy/azure/assets/83489863/c5880fb2-f9a7-4a0c-a8a4-9f34b99864e2)
