## Source: https://learn.microsoft.com/en-us/cli/azure/keyvault?view=azure-cli-latest

## Create Vault
```
az keyvault create --name "SymAKS" --resource-group "homeSG" --location "EastUS"
```
## How to create Secret
```
az keyvault secret set --vault-name "SymAKS" --name "ExamplePassword" --value "hVFkk965BuUv"
```

## How to get value


```
root@minikube02:~#  pip3 list | grep keyvault
azure-keyvault                                   4.0.0
azure-keyvault-certificates                      4.0.0
azure-keyvault-keys                              4.1.0b1
azure-keyvault-secrets                           4.1.0b1
azure-mgmt-keyvault                              2.0.0

```
