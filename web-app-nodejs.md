## This nodesjs web-app for Azure
```
root@pathflow-local /myworkspace # mkdir web-app-nodejs
root@pathflow-local /myworkspace # cd web-app-nodejs
root@pathflow-local /myworkspace/web-app-nodejs # ls
root@pathflow-local /myworkspace/web-app-nodejs # npm init
This utility will walk you through creating a package.json file.
It only covers the most common items, and tries to guess sensible defaults.

See `npm help json` for definitive documentation on these fields
and exactly what they do.

Use `npm install <pkg>` afterwards to install a package and
save it as a dependency in the package.json file.

Press ^C at any time to quit.
package name: (web-app-nodejs)
version: (1.0.0)
description:
entry point: (index.js)
test command:
git repository:
keywords:
author:
license: (ISC)
About to write to /myworkspace/web-app-nodejs/package.json:

{
  "name": "web-app-nodejs",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC"
}
Is this OK? (yes)

root@pathflow-local /myworkspace/web-app-nodejs # ls
package.json
root@pathflow-local /myworkspace/web-app-nodejs #
root@pathflow-local /myworkspace/web-app-nodejs #
root@pathflow-local /myworkspace/web-app-nodejs # cat package.json
{
  "name": "web-app-nodejs",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC"
}
```
## update start script
```
root@pathflow-local /myworkspace/web-app-nodejs # cat package.json
{
  "name": "web-app-nodejs",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "author": "",
  "license": "ISC"
}
```
## Start service to verify
```
root@pathflow-local /myworkspace/web-app-nodejs # npm start

> web-app-nodejs@1.0.0 start /myworkspace/web-app-nodejs
> node index.js

Server running at http://localhost:3000
```
## create environment variables
```
root@pathflow-local /myworkspace/web-app-nodejs # cat export.sh
export APPNAME=$(az webapp list --query [0].name --output tsv)
export APPRG=$(az webapp list --query [0].resourceGroup --output tsv)
export APPPLAN=$(az appservice plan list --query [0].name --output tsv)
export APPSKU=$(az appservice plan list --query [0].sku.name --output tsv)
export APPLOCATION=$(az appservice plan list --query [0].location --output tsv)
```


## push to Azure
```
az webapp up --name $APPNAME --resource-group $APPRG --plan $APPPLAN --sku $APPSKU --location "$APPLOCATION"
```




