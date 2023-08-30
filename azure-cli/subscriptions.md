## Subscriptions
```
# get the current default subscription using show
az account show --output table
EnvironmentName    IsDefault    Name                                         State    TenantId
-----------------  -----------  -------------------------------------------  -------  ------------------------------------
AzureCloud         True         Visual Studio Enterprise Subscription – MPN  Enabled  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# get the current default subscription using list
az account list --query "[?isDefault]"
root@minikube02:/myworkspace/azure/azure-cli# az account list --query "[?isDefault]"
[
  {
    "cloudName": "AzureCloud",
    "id": "xxxxxxxxxxxxxxxxxxxxx",
    "isDefault": true,
    "name": "Visual Studio Enterprise Subscription – MPN",
    "state": "Enabled",
    "tenantId": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "user": {
      "name": "Niranjan.Jannapureddy@genzeon.com",
      "type": "user"
    }
  }
]


# store the default subscription  in a variable
subscriptionId="$(az account list --query "[?isDefault].id" -o tsv)"
echo $subscriptionId



root@minikube02:/myworkspace/azure/azure-cli# az account show --output table
EnvironmentName    IsDefault    Name                                         State    TenantId
-----------------  -----------  -------------------------------------------  -------  ------------------------------------
AzureCloud         True         Visual Studio Enterprise Subscription – MPN  Enabled  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


```
## Change subscription
```
# change the active subscription using the subscription name
az account set --subscription "My Demos"

# change the active subscription using the subscription ID
az account set --subscription "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# change the active subscription using a variable
subscriptionId="$(az account list --query "[?isDefault].id" -o tsv)"
az account set --subscription $subscriptionId
```
## Create Subscription Locks
```
# az account lock list --output table




# az account lock create --name "Cannot delete subscription" --lock-type CanNotDelete
{
  "id": "/subscriptions/xxxxxxxxxxxxxxxxx/providers/Microsoft.Authorization/locks/Cannot delete subscription",
  "level": "CanNotDelete",
  "name": "Cannot delete subscription",
  "notes": null,
  "owners": null,
  "type": "Microsoft.Authorization/locks"
}

root@minikube02:# az account lock list --output table
Level         Name
------------  --------------------------
CanNotDelete  Cannot delete subscription

root@minikube02:/myworkspace/azure/azure-cli# az account lock show --name "Cannot delete subscription"
{
  "id": "/subscriptions/421461af-c23c-40ea-8be8-81a6f2b6400f/providers/Microsoft.Authorization/locks/Cannot delete subscription",
  "level": "CanNotDelete",
  "name": "Cannot delete subscription",
  "notes": null,
  "owners": null,
  "type": "Microsoft.Authorization/locks"
}

root@minikube02:/myworkspace/azure/azure-cli# az account lock delete --name "Cannot delete subscription"
root@minikube02:/myworkspace/azure/azure-cli# az account lock list --output table



```