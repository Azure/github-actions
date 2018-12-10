# GitHub Action for deploying to Azure Web App for Containers


## Usage

```

action "Deploy to Azure WebappContainer" {
  uses = "Azure/github-actions/containerwebapp@master"
  secrets = ["DOCKER_PASSWORD"]
  env = {
    AZURE_APP_NAME = "<Azure App Name>"
    DOCKER_USERNAME = "<Docker Registry username>"
    DOCKER_REGISTRY_URL = "<Docker Registry URL>"
    CONTAINER_IMAGE_NAME = "<Container Image Name>" 
  }
   needs = ["Azure Login"]
}

```


### Secrets

- `DOCKER_PASSWORD` – **Required** for private registry, this is the password used to log in to your Docker registry. 




### Environment variables

- `AZURE_APP_NAME` – **Required** 
- `DOCKER_REGISTRY_URL` – **Required** 
- `DOCKER_USERNAME` – **Required** for private registry, this is the username used to log in to your Docker registry.
- `CONTAINER_IMAGE_NAME` – **Required** 
- `CONTAINER_IMAGE_TAG` – **Optional** - ( default value =  "latest").  

