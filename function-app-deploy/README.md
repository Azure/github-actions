# GitHub Action for deploying to Azure Function App

To log into a Azure, we recommend using the [Azure Login](https://github.com/Azure/github-actions/tree/master/login) Action.


## Usage

```

action "Deploy to Azure  Function App" {
  uses = "Azure/github-actions/functions@master"
  needs = ["Azure Login"]
  env = {
    AZURE_APP_NAME = "<Azure App Name>"
    AZURE_APP_PACKAGE_LOCATION = "<Relative path in your repository to a folder/package containing application contents or containing a compressed zip file>"
  }
}

```




### Environment variables

- `AZURE_APP_NAME` – **Required** 
- `AZURE_APP_PACKAGE_LOCATION` – **Required** 

