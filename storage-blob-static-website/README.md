# GitHub Action for deploying to a Static Website in Azure Blob Storage

To log into a Azure, we recommend using the [Azure Login](https://github.com/Azure/github-actions/tree/master/login) Action.

## Usage

```
action "Upload to Static Website in Azure Blob Storage" {
  needs = ["Azure Login"]
  uses = "Azure/github-actions/static-website@master"
  env = {
    AZURE_STORAGE_ACCOUNT = "<Azure Storage Account>"
    PUBLIC_FOLDER = "<Public folder from which to deploy>"
  }
  secrets = [SAS_TOKEN]
}
```

## Configuration

### Environment variables

- `AZURE_STORAGE_ACCOUNT` – **Required** 
  > Name of your storage account

- `PUBLIC_FOLDER` - *Optional* (defaults to `public`)
  > Local file from which to upload contents

- `INDEX_FILE` - *Optional* (defaults to `index.html`)
  > The `index.html` file

- `NOT_FOUND_FILE` - *Optional* (defaults to `404.html`)
  > The file to be used in case of a `404` status code

- `SHOULD_EMPTY` - *Optional* (defaults to false)
  > Whether the `$web` container should be emptied before uploading new content

### Secrets

- `AZURE_STORAGE_SAS_TOKEN` + `AZURE_STORAGE_KEY`

> May be used (in combination) instead of the _Azure Login_ action to authenticate. See the [documentation](https://docs.microsoft.com/en-us/cli/azure/storage/blob?view=azure-cli-latest) for more information.

> Easily retrieve your key and generate a SAS token by using the Azure CLI. i.e.:
>
> ```bash
> az login # Login to Azure
> key=`az storage account keys list --account-name $AZURE_STORAGE_ACCOUNT` # Assuming AZURE_STORAGE_ACCOUNT holds the storage account name
> end=`date -v+30M '+%Y-%m-%dT%H:%MZ'` # Expiration date of the token (this will expire in 30 minutes)
> sas=`az storage account generate-sas --account-name $AZURE_STORAGE_ACCOUNT --account-key $key --resource-types c --services b --expiry $end --permissions adu`
> # `$key` will now hold your `AZURE_STORAGE_KEY` and `Ssas` will now hold your `AZURE_STORAGE_SAS_TOKEN`
> ```