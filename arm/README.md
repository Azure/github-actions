# GitHub Action for Managing Azure Resources

This action can be used to create or update a resource group in Azure using the [Azure Resource Manager templates](https://azure.microsoft.com/en-in/documentation/articles/resource-group-template-deploy/)
One can also use this to delete a resource group, including all the resources within the resource group.

To log into a Azure, we recommend using the [Azure Login](https://github.com/Azure/github-actions/tree/master/login) Action.



## Usage

```

action "Manage Azure Resources" {
  uses = "Azure/github-actions/arm@master"
  env = {
    AZURE_RESOURCE_GROUP = "<Resource Group Name"
    AZURE_TEMPLATE_LOCATION = "<URL or Relative path in your repository>"
    AZURE_TEMPLATE_PARAM_FILE = "<URL or Relative path in your repository>"
  }
  needs = ["Azure Login"]
}

```


### Environment variables


- `AZURE_RG_COMMAND` – **Optional**. 

  - If `AZURE_RG_COMMAND` is not specified or is "create"
    - `AZURE_RESOURCE_GROUP` – **Mandatory** 
    - `AZURE_TEMPLATE_LOCATION` – **Mandatory** - Can we a URL or relative path in your github repository
    - `AZURE_TEMPLATE_PARAM_LOCATION` – **Mandatory** - Can we a URL or relative path in your github repository
    
  -  If `AZURE_RG_COMMAND` is "delete"
     - `AZURE_RESOURCE_GROUP` – **Mandatory** 
  

