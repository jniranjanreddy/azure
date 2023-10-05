## How to set Subscriptions in CloudShell
```
# change the active subscription using the subscription name
az account set --subscription "My Demos"

# change the active subscription using the subscription ID
az account set --subscription "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# change the active subscription using a variable
subscriptionId="$(az account list --query "[?name=='my case sensitive subscription full name'].id" --output tsv)"
az account set --subscription $subscriptionId
```
