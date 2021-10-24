# iac-demo
Simple IaC templates, both ARM, Bicep and Terraform for demo purposes

## Prerequisites to run the code

The demonstration material will only work on Azure Resources. 
You will need an Azure Subscription where you can deploy the resources. The code only needs a subscription ID to function.  

Also, you need the following installed: 

-  Az PowerShell module: https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-6.5.0
- Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli
- Bicep: https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-cli
- Terraform CLI: https://learn.hashicorp.com/tutorials/terraform/install-cli

In order to run any of the Azure CLI Commands in the Bicep and Terraform folder, you will need to install the Az CLI and read the section below.

## Azure CLI - Get started

Before you run any Azure CLI commands, you will need to sign in. 

```
az login
```

You will be redirected to sign-in page and you will have to sign in with an account that has access to the subscription you will use. If your account has access to multiple subscriptions, these will be listed in the output after sign in. However, it will be useful to know how to navigate and switch between subscriptions using the Azure CLI. 

```PowerShell
    az account list # This will list all available subscriptions in you user context.
    az account show # Shows the 'active' subscription context.
    az account set -s <Subscription ID> # Copy the 'subscription id' from your account list and paste here to set this as you current context.
```

Hopefully you now have what it takes to get started with Azure CLI and deploy resources in you subscriptions! 
