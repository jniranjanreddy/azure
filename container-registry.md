## Azure Container registry

```
Once registry created from GUI

in the cli mose execute below commands
az login
az acr login --name pcregistry.azurecr.io
it will go through authentication process, once done, can able to push and pull images

docker tag gcr.io/google-samples/hello-app:1.0 pcregistry.azurecr.io/hello-world:v1
docker push pcregistry.azurecr.io/hello-world:v1

docker push pcregistry.azurecr.io/hello-world:v1
The push refers to repository [pcregistry.azurecr.io/hello-world]
3b8ca1afdf65: Pushed
2aebd096e0e2: Pushed
v1: digest: sha256:c62ead5b8c16c266d0fcddd93fea882eb722c3be4 size: 739

```
