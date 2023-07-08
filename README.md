## Azure Local

```
C:\Users\NJannapureddy> winget install Microsoft.AzureFunctionsCoreTools
Found Azure Functions Core Tools [Microsoft.AzureFunctionsCoreTools] Version 4.0.4785
This application is licensed to you by its owner.
Microsoft is not responsible for, nor does it grant any licenses to, third-party packages.
Downloading https://github.com/Azure/azure-functions-core-tools/releases/download/4.0.4785/func-cli-4.0.4785-x64.msi
  ██████████████████████████████   147 MB /  147 MB
Successfully verified installer hash
Starting package install...
Successfully installed

C:\Users\NJannapureddy>

```
## How to add Azure login in github actions
```



## Source: https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-cli%2Clinux#use-the-azure-login-action-with-a-service-principal-secret

## Create Service Principal
root@ubansinode1:~# az ad sp create-for-rbac --name "myApp" --role contributor \
> --scopes /subscriptions/<Subscription-ID>/resourceGroups/<Resource-Group> \
> --sdk-auth
Option '--sdk-auth' has been deprecated and will be removed in a future release.
Creating 'contributor' role assignment under scope '/subscriptions/<Subscription-ID>/resourceGroups/for-devops'
The output includes credentials that you must protect. Be sure that you do not include these credentials in your code or check the credentials into your source control. For more information, see https://aka.ms/azadsp-cli
{
  "clientId": "xxxxxxxxx",
  "clientSecret": "xxxxxxxxxx",
  "subscriptionId": "xxxxxxxx",
  "tenantId": "xxxxxxxx",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net
 }
 
 
 ## Add secreats
 Azure-->
 
 
 
 ##deploy.yaml
 on: [push]

name: AzureLoginSample

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Log in with Azure
        uses: azure/login@v1
        with:
          creds: '${{ secrets.AZURE_CREDENTIALS }}'
		  
	  - name: 'Run Azure CLI commands'
        run: |
           az account show
           az group list
           pwd	  
```


