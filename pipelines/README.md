# GitHub Action for triggering Azure YAML Pipelines



## Usage

```

action "Trigger Azure Pipelines" {
  uses = "Azure/github-actions/pipelines@master"
  env = {
		AZURE_DEVOPS_URL = "<Azure DevOps URL>"
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

One of `AZURE_DEVOPS_URL` or `AZURE_DEVOPS_ORGANIZATION` is mandatory.
In case both are defined, `AZURE_DEVOPS_URL` gets preference.

- `AZURE_DEVOPS_URL` – **Optional**; the fully-qualified URL to the Azure DevOps organization (eg, `https://dev.azure.com/organization` or `https://server.example.com:8080/tfs/DefaultCollection`)
- `AZURE_DEVOPS_ORGANIZATION` – **Optional**; the Azure DevOps organization name.  The URL to Azure DevOps will be derived from this.

Additional configuration:

- `AZURE_DEVOPS_PROJECT` – **Mandatory** 
- `AZURE_PIPELINE_NAME` – **Mandatory** 



