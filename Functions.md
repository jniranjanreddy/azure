## Source https://www.youtube.com/watch?v=zIfxkub7CLY
## https://www.youtube.com/playlist?list=PLD-lHCDqiS8aLuipHciNM4MhPuXRqw087 - Python
## Source https://github.com/Azure/azure-functions-core-tools?tab=readme-ov-file
## Func Cli - https://www.youtube.com/watch?v=D1kL-WMMZZY&t=1s
## https://www.youtube.com/watch?v=eS5GJkI69Qg&list=PLMWaZteqtEaLRsSynAsaS_aLzDPBUU4CV

## Description-
```
Azure function is a serverless solution
1. charges based on consumption
2. needed storage account.

```


```
PS C:\Users\azure-functions> func

Azure Functions Core Tools
Core Tools Version:       4.0.5530 Commit hash: N/A +c8883e7f3c06e2b424fbac033806c19d8d91418c (64-bit)
Function Runtime Version: 4.28.5.21962

Usage: func [context] [context] <action> [-/--options]

Contexts:
azure               Commands to log in to Azure and manage resources
azurecontainerapps  Commands for working with Container Service and Azure Functions
durable             Commands for working with Durable Functions
extensions          Commands for installing extensions
function            Commands for creating and running functions locally
host                Commands for running the Functions host locally
kubernetes          Commands for working with Kubernetes and Azure Functions
settings            Commands for managing environment settings for the local Functions host
templates           Commands for listing available function templates

```
## func init
```
mkdir function-examples
cd function-examples
func init
PS C:\Users\azure\azure-functions\example-1> func init
Use the up/down arrow keys to select a worker runtime:python
Found Python version 3.10.11 (python3).
The new Python programming model is generally available. Learn more at https://aka.ms/pythonprogrammingmodel
Writing requirements.txt
Writing function_app.py
Writing .gitignore
Writing host.json
Writing local.settings.json
Writing C:\Users\azure\azure-functions\example-1\.vscode\extensions.json
PS C:\Users\\azure\azure-functions\example-1>
```
## Func new
```
PS C:\Users\NJannapureddy\azure\azure-functions\example-1> func new
Use the up/down arrow keys to select a template:
Blob trigger
CosmosDB trigger
EventGrid trigger
EventHub trigger
HTTP trigger
Queue trigger
ServiceBus Queue trigger
ServiceBus Topic trigger
Timer Trigger
```
## 









