# GitHub Action for creating work items in Azure Boards

An action to create a work item in Azure Boards that corresponds to
a GitHub issue.  Subsequent comments in the issue will be created as
discussion entries in the Azure Boards work item.  When the GitHub
issue is closed, the corresponding work item will also be moved to the
"Done" state.

## Usage

```
action "Create Azure Boards Work Item" {
  uses = "azure/github-actions/boards@master"
  env = {
		AZURE_BOARDS_ORGANIZATION = "<Azure Boards Organization Name>"
		AZURE_BOARDS_PROJECT = "<Azure Boards Project Name>"
		AZURE_BOARDS_TYPE= "<Azure Boards Work Item Type>"
		AZURE_BOARDS_CLOSED_STATE= "<Azure Boards Work Item State>"
		AZURE_BOARDS_REOPENED_STATE= "<Azure Boards Work Item State>"
	}
  secrets = ["AZURE_BOARDS_TOKEN"]
}
```

### Secrets

- `AZURE_BOARDS_TOKEN` – **Mandatory** 


### Environment variables

- `AZURE_BOARDS_ORGANIZATION` – **Mandatory**
- `AZURE_BOARDS_PROJECT` – **Mandatory** 
- `AZURE_BOARDS_TYPE` – **Optional**; the type of work item to create.  Defaults to "Feature" if unset.
- `AZURE_BOARDS_CLOSED_STATE` - **Optional**; the state to move the work item to when the GitHub issue is closed.  Defaults to "Done" if unset.
- `AZURE_BOARDS_REOPENED_STATE` - **Optional**; the state to move the work item to when the GitHub issue is reopened.  Defaults to "New" if unset.

