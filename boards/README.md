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
		AZURE_DEVOPS_URL = "<Azure DevOps URL>"
		AZURE_DEVOPS_PROJECT = "<Azure DevOps Project Name>"
		AZURE_BOARDS_TYPE= "<Azure Boards Work Item Type>"
		AZURE_BOARDS_CLOSED_STATE= "<Azure Boards Work Item State>"
		AZURE_BOARDS_REOPENED_STATE= "<Azure Boards Work Item State>"
	}
  secrets = ["AZURE_DEVOPS_TOKEN"]
}
```

### Secrets

- `AZURE_DEVOPS_TOKEN` – **Mandatory**; an access token to be used when creating/updating work items.  See [Authenticate access with personal access tokens](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops) for details. 


### Environment variables

- `AZURE_DEVOPS_URL` – **Mandatory**; the fully-qualified URL to the Azure DevOps organization (eg, `https://dev.azure.com/organization` or `https://server.example.com:8080/tfs/DefaultCollection`)
- `AZURE_DEVOPS_PROJECT` – **Mandatory**; the name of the Azure DevOps project that contains the boards
- `AZURE_BOARDS_TYPE` – **Optional**; the type of work item to create.  Defaults to "Feature" if unset.  See [process doeumentation](https://docs.microsoft.com/en-us/azure/devops/boards/work-items/guidance/choose-process?view=azure-devops) for more details on work item types.
- `AZURE_BOARDS_CLOSED_STATE` - **Optional**; the state to move the work item to when the GitHub issue is closed.  Defaults to "Closed" if unset.
- `AZURE_BOARDS_REOPENED_STATE` - **Optional**; the state to move the work item to when the GitHub issue is reopened.  Defaults to "New" if unset.

