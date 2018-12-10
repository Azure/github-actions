 
# GitHub Action for deploying to Azure K8S Service


## Usage

```workflow

action "Deploy to Azure Kubernetes Service" {
  uses = "Azure/github-actions/aks@master"
  secrets = ["DOCKER_PASSWORD", "KUBE_CONFIG_DATA"]
  env = {
    AKS_CLUSTER_NAME = "<AKS Cluster Name>"
    DOCKER_USERNAME = "<Docker Registry username>"
    DOCKER_REGISTRY_URL = "<Docker Registry URL>"
    CONTAINER_IMAGE_NAME = "<Container Image Name>" 
  }
}

```


### Secrets

- `DOCKER_PASSWORD` – **Optional** if public registry or if trust has been established with AKS. This is the password used to log in to your Docker registry. 
- `KUBE_CONFIG_DATA` - **Optional**. "kubectl config" file content with credentials for Kubernetes to access the cluster. If we use this option, we wont need ["Azure Login"] action as a precursor to this one. 



### Environment variables

- `AKS_CLUSTER_NAME` – **Required** 
- `DOCKER_REGISTRY_URL` – **Required** 
- `CONTAINER_IMAGE_NAME` – **Required** 
- `DOCKER_USERNAME` – **Optional** if public registry or if trust has been established with AKS. This is the username used to log in to your Docker registry.
- `CONTAINER_IMAGE_TAG` – **Optional** ( default value =  "latest")
- `HELM_RELEASE_NAME` - **Optional** ( default value =  "aks-deploy")
- `HELM_CHART_PATH` - **Optional** ( default value =  ./default-chart) 
 

