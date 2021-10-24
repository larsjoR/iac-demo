terraform {
  backend "azurerm" {
    subscription_id      = "<Subscription ID>"
    resource_group_name  = "Terrastate"
    storage_account_name = "terrademostate"
    container_name       = "state"
    key                  = "demotfstate"
    access_key           = "<Storage Account KEY>"
  }
}