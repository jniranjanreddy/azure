## How to deploy to App services on container

## Source
```
trigger:
- main

resources:
- repo: self

variables: 
  ## Add this under variables section in the pipeline
  azureSubscription: <Name of the Azure subscription>
  appName: <Name of the Web App>
  containerRegistry: <Name of the Azure container registry>
  dockerRegistryServiceConnection: '4fa4efbc-59af-4c0b-8637-1d5bf7f268fc'
  imageRepository: <Name of image repository>
  dockerfilePath: '$(Build.SourcesDirectory)/Dockerfile'
  tag: '$(Build.BuildId)'

  vmImageName: 'ubuntu-latest'

stages:
- stage: Build
  displayName: Build and push stage
  jobs:
  - job: Build
    displayName: Build
    pool:
      vmImage: $(vmImageName)
    steps:
    - task: Docker@2
      displayName: Build and push an image to container registry
      inputs:
        command: buildAndPush
        repository: $(imageRepository)
        dockerfile: $(dockerfilePath)
        containerRegistry: $(dockerRegistryServiceConnection)
        tags: |
          $(tag)


    ## Add the below snippet at the end of your pipeline
    - task: AzureWebAppContainer@1
      displayName: 'Azure Web App on Container Deploy'
      inputs:
        azureSubscription: $(azureSubscription)
        appName: $(appName)
        imageName: $(containerRegistry)/$(imageRepository):$(tag)
```
