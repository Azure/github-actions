# GitHub Action for creating work items in Azure Boards



## Usage

```

action "Create Azure Boards Work Item" {
  uses = "mmitrik/github-actions/boards@master"
  env = {
		AZURE_BOARDS_ORGANIZATION = "<Azure Boards Organization Name>"
		AZURE_BOARDS_PROJECT = "<Azure Boards Project Name>"
		AZURE_BOARDS_TYPE= "<Azure Boards Work Item Type>"
		AZURE_BOARDS_TITLE= "<Azure Boards Work Item Title>"
		AZURE_BOARDS_DESCRIPTION = "<Azure Boards Work Item Description>"
	}
  secrets = ["AZURE_BOARDS_TOKEN"]
}

```


### Secrets

- `AZURE_BOARDS_TOKEN` – **Mandatory** 


### Environment variables

- `AZURE_BOARDS_ORGANIZATION` – **Mandatory** 
- `AZURE_BOARDS_PROJECT` – **Mandatory** 
- `AZURE_BOARDS_TYPE` – **Mandatory** 
- `AZURE_BOARDS_TITLE` – **Mandatory** 
- `AZURE_BOARDS_DESCRIPTION` – **Mandatory** 


