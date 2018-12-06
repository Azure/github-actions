# GitHub Action for triggering Azure YAML Pipelines



## Usage

```

action "Trigger Azure Pipelines" {
  uses = "actions/azure/pipelines@master"
  env = {
		AZURE_PIPELINE_ORGANIZATION = "<Azure Organization Name>"
		AZURE_PIPELINE_PROJECT = "<Azure Project Name>"
		AZURE_PIPELINE_NAME= "<Azure Pipeline Name>"
	}
  secrets = ["AZURE_PIPELINE_TOKEN"]
}

```


### Secrets

- `AZURE_PIPELINE_TOKEN` – **Mandatory** 


### Environment variables

- `AZURE_PIPELINE_ORGANIZATION` – **Mandatory** 
- `AZURE_PIPELINE_PROJECT` – **Mandatory** 
- `AZURE_PIPELINE_NAME` – **Mandatory** 



