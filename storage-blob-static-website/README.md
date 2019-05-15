# GitHub Action for deploying to a Static Website in Azure Blob Storage

## Usage

```workflow
action "Upload to Static Website in Azure Blob Storage" {
  needs = "AzureLogin"
  uses = "Azure/github-actions/storage-blob-static-website@master"
  env = {
    AZURE_STORAGE_ACCOUNT = "<Azure Storage Account>"
    PUBLIC_FOLDER = "<Public folder from which to deploy>"
  }
  secrets = [
    "AZURE_STORAGE_ACCOUNT",
    "SAS_TOKEN"
  ]
}
```

> See [the examples page](./EXAMPLES.md) for examples.

## Configuration

### Environment variables

- `PUBLIC_FOLDER` - *Optional* (defaults to `public`)
  > Local file from which to upload contents

- `INDEX_FILE` - *Optional* (defaults to `index.html`)
  > The `index.html` file

- `NOT_FOUND_FILE` - *Optional* (defaults to `404.html`)
  > The file to be used in case of a `404` status code

- `SHOULD_EMPTY` - *Optional*
  > Whether the `$web` container should be emptied before uploading new content
  > Set to `true` if you wish to empty the `$web` container before uploading.

### Secrets

- `AZURE_STORAGE_ACCOUNT`
  
  Name of the storage account in which the static website is to be hosted

- `SAS_TOKEN`
  
  May be used (in combination) instead of the _Azure Login_ action to authenticate. See the [documentation](https://docs.microsoft.com/en-us/cli/azure/storage/blob?view=azure-cli-latest) for more information.

  > Easily retrieve your key and generate a SAS token by using the Azure CLI. i.e.:
  >
  > ```bash
  > az login # Login to Azure
  > az storage account keys list --account-name $AZURE_STORAGE_ACCOUNT
  > # ...Retrieve relevant key from JSON response and store in `$key`
  > end=`date -v+30M '+%Y-%m-%dT%H:%MZ'` # Expiration date of the token (this will expire in 30 minutes)
  > sas=`az storage account generate-sas --account-name $AZURE_STORAGE_ACCOUNT --account-key $key --resource-types c --services b --expiry $end --permissions adu`
  > # `$key` will now hold your `AZURE_STORAGE_KEY` and `$sas` will now hold your `AZURE_STORAGE_SAS_TOKEN`
  > ```