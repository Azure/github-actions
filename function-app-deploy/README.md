# GitHub Action for deploying to Azure Function App


## Usage

```

action "Deploy to Azure  Function App" {
  uses = "Azure/github-actions/functions@master"
  needs = ["Azure Login"]
  env = {
    AZURE_APP_NAME = "<Azure App Name>"
    AZURE_APP_PACKAGE_LOCATION = "<Relative path in your repository>"
  }
}

```




### Environment variables

- `AZURE_APP_NAME` – **Required** 
- `AZURE_APP_PACKAGE_LOCATION` – **Required** 

