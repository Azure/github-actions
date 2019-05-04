# Usage with NPM

> Assumes project is built with a build script named `build` into a `/public` folder.

```workflow
workflow "Build and deploy on push" {
  on = "push"
  resolves = ["StorageDeploy"]
}

action "Install" {
  uses = "actions/npm@master"
  args = "install"
}

action "Build" {
  needs = "Install"
  uses = "actions/npm@master"
  args = "run build"
}

action "AzureLogin" {
  needs = "Build"
  uses = "Azure/github-actions/login@master"
  env = {
    AZURE_SUBSCRIPTION = "<name of your subscription here>"
  }
  secrets = [
    "AZURE_SERVICE_PASSWORD",
    "AZURE_SERVICE_TENANT",
    "AZURE_SERVICE_APP_ID",
  ]
}

action "AzureDeployToStaticWebsite" {
  needs = "AzureLogin"
  uses = "Azure/github-actions/static-website@master"
  secrets = [
    "AZURE_STORAGE_ACCOUNT",
    "SAS_TOKEN"
  ]
}
```