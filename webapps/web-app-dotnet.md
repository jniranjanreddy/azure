## What is azure webapp
## Source: https://learn.microsoft.com/en-us/training/modules/host-a-web-app-with-azure-app-service/ 

## Create project
```
root@ubansinode1:~# dotnet new mvc --name first-web-app

Welcome to .NET 6.0!
---------------------
SDK Version: 6.0.411

Telemetry
---------
The .NET tools collect usage data in order to help us improve your experience. It is collected by Microsoft and shared with the community. You can opt-out of telemetry by setting the DOTNET_CLI_TELEMETRY_OPTOUT environment variable to '1' or 'true' using your favorite shell.

Read more about .NET CLI Tools telemetry: https://aka.ms/dotnet-cli-telemetry

----------------
Installed an ASP.NET Core HTTPS development certificate.
To trust the certificate run 'dotnet dev-certs https --trust' (Windows and macOS only).
Learn about HTTPS: https://aka.ms/dotnet-https
----------------
Write your first app: https://aka.ms/dotnet-hello-world
Find out what's new: https://aka.ms/dotnet-whats-new
Explore documentation: https://aka.ms/dotnet-docs
Report issues and find source on GitHub: https://github.com/dotnet/core
Use 'dotnet --help' to see available commands or visit: https://aka.ms/dotnet-cli
--------------------------------------------------------------------------------------
The template "ASP.NET Core Web App (Model-View-Controller)" was created successfully.
This template contains technologies from parties other than Microsoft, see https://aka.ms/aspnetcore/6.0-third-party-notices for details.

Processing post-creation actions...
Running 'dotnet restore' on /root/first-web-app/first-web-app.csproj...
  Determining projects to restore...
  Restored /root/first-web-app/first-web-app.csproj (in 280 ms).
Restore succeeded.
```
## Publish
```
root@ubansinode1:~/first-web-app# dotnet publish -o pub
MSBuild version 17.3.2+561848881 for .NET
  Determining projects to restore...
  All projects are up-to-date for restore.
  first-web-app -> /root/first-web-app/bin/Debug/net6.0/first-web-app.dll
  first-web-app -> /root/first-web-app/pub/

cd pub
zip -r site.zip *
```
## Push to Azure
```
az webapp deployment source config-zip \
    --src site.zip \
    --resource-group [sandbox resource group name] \
    --name <your-app-name>

root@ubansinode1:~/first-web-app/pub# az webapp deployment source config-zip \
>     --src site.zip \
>     --resource-group learn-70a33bc5-e0b5-41a0-a930-d8261aba71ce \
>     --name myapache
Getting scm site credentials for zip deployment
Starting zip deployment. This operation can take a while to complete ...
Deployment endpoint responded with status code 202
{
  "active": true,
  "author": "N/A",
  "author_email": "N/A",
  "build_summary": {
    "errors": [],
    "warnings": []
  },
  "complete": true,
  "deployer": "Push-Deployer",
  "end_time": "2023-06-29T16:26:45.6190606Z",
  "id": "eb1c9dfb-5260-4e93-8551-0a7248b29b6e",
  "is_readonly": true,
  "is_temp": false,
  "last_success_end_time": "2023-06-29T16:26:45.6190606Z",
  "log_url": "https://myapache.scm.azurewebsites.net/api/deployments/latest/log",
  "message": "Created via a push deployment",
  "progress": "",
  "received_time": "2023-06-29T16:26:39.3273273Z",
  "site_name": "myapache",
  "start_time": "2023-06-29T16:26:40.8019055Z",
  "status": 4,
  "status_text": "",
  "url": "https://myapache.scm.azurewebsites.net/api/deployments/latest"
}



```
