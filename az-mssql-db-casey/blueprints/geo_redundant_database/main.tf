module "geo_redundant_mssql" {
  source = "../../atomic"

  environment           = var.environment
  location              = var.location
  subscription_id       = var.subscription_id
  tenant_id             = var.tenant_id
  resource_group_name   = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  key_vault_id          = var.key_vault_id

  mssql_config = {
    server = {
      name                             = var.server_name
      create_resource_group            = var.create_resource_group
      location                         = var.location
      secondary_location               = var.secondary_location
      version                          = "12.0"
      administrator_login              = var.admin_login
      administrator_login_password     = var.admin_password
      minimum_tls_version              = "1.2"
      public_network_access_enabled    = false
      outbound_network_restriction_enabled = true
      enable_monitoring                = var.enable_monitoring
      enable_threat_detection          = true
      enable_failover_group            = true
      failover_group_name              = var.failover_group_name
      azuread_administrator = {
        login_username = var.azuread_login_username
        object_id      = var.azuread_object_id
      }
      tags = var.tags
    }

    databases = {
      for db_name, db in var.databases : db_name => merge(db, {
        failover_group_enabled = true,
        secondary_location     = var.secondary_location
      })
    }
  }
}
