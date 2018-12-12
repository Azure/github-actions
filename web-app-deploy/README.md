# GitHub Action for deploying  to Azure Web App


## Usage

```

action "Deploy to Web App" {
  uses = "Azure/github-actions/webapp@master"
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

