# GitHub Action for triggering Azure YAML Pipelines



## Usage

```

action "Trigger Azure Pipelines" {
  uses = "Azure/github-actions/pipelines@master"
  env = {
		AZURE_DEVOPS_ORGANIZATION = "<Azure DevOps Organization Name>"
		AZURE_DEVOPS_PROJECT = "<Azure DevOps Project Name>"
		AZURE_PIPELINE_NAME= "<Azure Pipeline Name>"
	}
  secrets = ["AZURE_DEVOPS_TOKEN"]
}

```


### Secrets

- `AZURE_DEVOPS_TOKEN` – **Mandatory** 


### Environment variables

- `AZURE_DEVOPS_ORGANIZATION` – **Mandatory** 
- `AZURE_DEVOPS_PROJECT` – **Mandatory** 
- `AZURE_PIPELINE_NAME` – **Mandatory** 



