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
- `PUBLIC_FOLDER` - *Optional* (defaults to `public`)

### Secrets

- `SAS_TOKEN`