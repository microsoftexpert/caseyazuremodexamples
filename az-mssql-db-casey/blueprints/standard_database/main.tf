module "standard_database" {
  source = "../../atomic"

  environment                 = var.environment
  location                    = var.location
  subscription_id             = var.subscription_id
  tenant_id                   = var.tenant_id
  resource_group_name         = var.resource_group_name
  key_vault_id                = var.key_vault_id
  log_analytics_workspace_id  = var.log_analytics_workspace_id

  mssql_config = {
    server = {
      name                                 = var.server_name
      create_resource_group                = var.create_resource_group
      version                              = "12.0"
      minimum_tls_version                  = "1.2"
      public_network_access_enabled        = true
      outbound_network_restriction_enabled = false
      enable_monitoring                    = var.enable_monitoring
      enable_threat_detection              = true
      azuread_administrator = {
        login_username = var.azuread_login_username
        object_id      = var.azuread_object_id
      }
      tags = var.tags
    }

    databases = var.databases
  }
}
