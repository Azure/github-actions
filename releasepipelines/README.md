# GitHub Action for triggering Azure Release Pipelines



## Usage

```

action "Trigger Azure Release Pipelines" {
  uses = "Azure/github-actions/releasepipelines@master"
  env = {
		AZURE_DEVOPS_URL = "<Azure DevOps URL>"
		AZURE_DEVOPS_PROJECT = "<Azure DevOps Project Name>"
		AZURE_PIPELINE_NAME= "<Azure Pipeline Name>"
	}
  secrets = ["AZURE_DEVOPS_TOKEN"]
}

```


### Secrets

- `AZURE_DEVOPS_TOKEN` – **Mandatory** 


### Environment variables

- `AZURE_DEVOPS_URL` – **Mandatory**; the fully-qualified URL to the Azure DevOps organization (eg, `https://dev.azure.com/organization` or `https://server.example.com:8080/tfs/DefaultCollection`)
- `AZURE_DEVOPS_PROJECT` – **Mandatory** 
- `AZURE_PIPELINE_NAME` – **Mandatory** 



