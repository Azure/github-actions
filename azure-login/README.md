# GitHub Action for the Azure Login

The GitHub Action for [Azure](https://azure.microsoft.com/) Login wraps the Azure CLI's `az login`, allowing for Actions to log into Azure.

Because `$HOME` is persisted across Actions, the `az login` command will save this information on the filesystem, allowing other Actions to reuse the context.


## Usage

```

 action "Azure Login" {
  uses = "Azure/github-actions/login@master"
  env = {
    AZURE_SUBSCRIPTION = "Subscription Name"
  }
  secrets = ["AZURE_SERVICE_APP_ID", "AZURE_SERVICE_PASSWORD", "AZURE_SERVICE_TENANT"]
}

```


### Secrets

- `AZURE_SERVICE_APP_ID` – **Required** 
- `AZURE_SERVICE_PASSWORD` – **Required** 
- `AZURE_SERVICE_TENANT` – **Required** 


You can create get the above details by running " az ad sp create-for-rbac " command([more info](https://docs.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az-ad-sp-create-for-rbac)).





### Environment variables

- `AZURE_SUBSCRIPTION` – **Optional** if have access to just one subscription


