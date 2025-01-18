## Trouble shooting of webapps
```
1. if vnet is configured, create App service plans for all web apps
2, create private endpoints.
```
## How to check if Function App is in the same network as Web apps.
```
1. Go to any web app with in the same Vnet
2. Diagnose and solve problems.
3. Diagnostic Tools -> Network Trouble shooter -> Connection Issues -> it may through errors, then refresh, it will be normal
4. it will ask for a <endpointurl:443> provide the function app name and port OR ip of the function app nic.
5. if its in the same Nework
Result - Connecting to 192.168.100.142:443 from your App instance - OK (TCP level)

```
