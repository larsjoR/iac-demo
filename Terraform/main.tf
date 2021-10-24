provider "azurerm" {
  features {}
}

# Data blocks to access current config / subscription
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

# Resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resourceGroupName 
  location = var.location
}

# Application insights
resource "azurerm_application_insights" "portal" {
  name                = "${var.prefix}-${var.environment}-appi-${var.suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# App service plan
resource "azurerm_app_service_plan" "web" {
  name                = "${var.prefix}-${var.environment}-plan-web-${var.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Windows"

  sku {
    tier = "Free"
    size = "F1"
  }
}

# The web app itself
resource "azurerm_app_service" "webapp" {
  name                = "${var.prefix}-${var.environment}-web-${var.suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.web.id

  site_config {
    always_on                 = false
    http2_enabled             = true
    use_32_bit_worker_process = true
    websockets_enabled        = true
    dotnet_framework_version  = "v5.0"
  }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.portal.instrumentation_key
    UserAssignedIdentityClientId          = azurerm_user_assigned_identity.identity_portal.client_id
    KeyVaultName                          = azurerm_key_vault.kv.name
    SCM_ZIPDEPLOY_DONOT_PRESERVE_FILETIME = "1"
    WEBSITE_LOAD_CERTIFICATES             = "*"
    UseKeyVault                           = true
    "Logging:LogLevel:Default"            = "Warning"
    "AzureAD:CallbackPath"                = "/signin-oidc"
    "AzureAD:Instance"                    = "https://login.microsoftonline.com/"
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.identity_portal.id
    ]
  }
}

# Webapps need UAI in order to actually provision without failure (which happens when using system assigned)
resource "azurerm_user_assigned_identity" "identity_portal" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  name = "${var.prefix}-${var.environment}-identity-${var.suffix}-portal"
}

# KeyVault to contain config secrets
resource "azurerm_key_vault" "kv" {
  name                        = "${var.prefix}-${var.environment}-kv-${var.suffix}"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled    = false

  sku_name = "standard"

  tags = {}
}

# Grant the current user access to the key vault, in order to create secrets (clientid, etc.)
resource "azurerm_key_vault_access_policy" "self" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = []

  secret_permissions = [
    "get", "set", "delete", "list", "recover", "purge"
  ]

  storage_permissions = []

  certificate_permissions = []
}

# Grant the webapp "get permission" to the KeyVault
resource "azurerm_key_vault_access_policy" "portal" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_user_assigned_identity.identity_portal.principal_id

  secret_permissions = [
    "get"
  ]

  storage_permissions     = []
  key_permissions         = []
  certificate_permissions = []
}

# Secret clientsecret
resource "azurerm_key_vault_secret" "clientSecret" {
  name         = "clientSecret"
  value        = var.clientSecret
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [
    azurerm_key_vault_access_policy.self
  ]
}

# Output webapp name
output "webapp_name" {
  value = azurerm_app_service.webapp.name
}
