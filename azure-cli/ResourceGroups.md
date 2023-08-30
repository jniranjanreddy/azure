## Resource Groups
```
root@minikube02:/myworkspace/azure/azure-cli# az group list --output table
Name                                Location        Status
----------------------------------  --------------  ---------
cloud-shell-storage-southcentralus  southcentralus  Succeeded
DefaultResourceGroup-EUS            eastus          Succeeded
webapps                              eastus          Succeeded
ForDevops                            eastus          Succeeded

root@minikube02:/myworkspace/azure/azure-cli# az group delete --name nirulabs
Are you sure you want to perform this operation? (y/n): y
 - Running ..
 - Running ..


```
## o set a default resource group for your Azure CLI installation, run the az config se

```
az config set defaults.group=MyResourceGroup
```