resource "azurerm_resource_group" "this" {
  count    = var.mssql_config.server.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
}
resource "random_password" "mssql_admin" {
  length  = 24
  special = true
}

# PRIMARY SQL SERVER
resource "azurerm_mssql_server" "primary" {
  name                                 = var.mssql_config.server.name
  resource_group_name                  = var.resource_group_name
  location                             = var.location
  version                              = var.mssql_config.server.version
  minimum_tls_version                  = var.mssql_config.server.minimum_tls_version
  public_network_access_enabled        = var.mssql_config.server.public_network_access_enabled
  outbound_network_restriction_enabled = var.mssql_config.server.outbound_network_restriction_enabled

  # Required to satisfy provider: must set login + password (even if not used)
  administrator_login                     = "adonlyadmin"
  # administrator_login_password_wo         = random_password.mssql_admin.result
  # administrator_login_password_wo_version = 1

  primary_user_assigned_identity_id            = local.sql_primary_user_assigned_identity_id
  transparent_data_encryption_key_vault_key_id = local.tde_key_vault_key_id

  dynamic "azuread_administrator" {
    for_each = var.mssql_config.server.azuread_administrator != null ? [var.mssql_config.server.azuread_administrator] : []
    content {
      login_username              = azuread_administrator.value.login_username
      object_id                   = azuread_administrator.value.object_id
      azuread_authentication_only = true
    }
  }
  dynamic "identity" {
    for_each = [1]
    content {
      type         = var.key_vault_id != null ? "SystemAssigned" : try(var.mssql_config.server.identity.type, null)
      identity_ids = try(var.mssql_config.server.identity.identity_ids, null)
    }
  }
  lifecycle {
    ignore_changes = [
      primary_user_assigned_identity_id,
      administrator_login,
      administrator_login_password_wo,
      administrator_login_password_wo_version
    ]
  }
  tags = var.mssql_config.server.tags
}
# SECONDARY SQL SERVER (Only created if Failover Group is enabled)
resource "azurerm_mssql_server" "secondary" {
  count                                = var.mssql_config.server.enable_failover_group ? 1 : 0
  name                                 = "${var.mssql_config.server.name}-secondary"
  resource_group_name                  = var.resource_group_name
  location                             = var.mssql_config.server.secondary_location
  version                              = var.mssql_config.server.version
  minimum_tls_version                  = var.mssql_config.server.minimum_tls_version
  public_network_access_enabled        = var.mssql_config.server.public_network_access_enabled
  outbound_network_restriction_enabled = var.mssql_config.server.outbound_network_restriction_enabled

  # Required for Terraform validation even when using Azure AD auth only
  administrator_login                     = "adonlyadmin"
  # administrator_login_password_wo         = random_password.mssql_admin.result
  # administrator_login_password_wo_version = 1

  dynamic "azuread_administrator" {
    for_each = var.mssql_config.server.azuread_administrator != null ? [var.mssql_config.server.azuread_administrator] : []
    content {
      login_username              = azuread_administrator.value.login_username
      object_id                   = azuread_administrator.value.object_id
      azuread_authentication_only = true
    }
  }

  dynamic "identity" {
    for_each = [1]
    content {
      type         = var.key_vault_id != null ? "SystemAssigned" : try(var.mssql_config.server.identity.type, null)
      identity_ids = try(var.mssql_config.server.identity.identity_ids, null)
    }
  }

  #  Simplified logic for user-assigned identity fallback
  primary_user_assigned_identity_id = (
    var.key_vault_id != null
    ? azurerm_mssql_server.primary.identity[0].principal_id
    : contains(["UserAssigned", "SystemAssigned, UserAssigned", "UserAssigned, SystemAssigned"], try(var.mssql_config.server.identity.type, ""))
    ? var.mssql_config.server.user_assigned_identity_id
    : null
  )

  tags = var.mssql_config.server.tags
}

# DATABASE CREATION (On Primary Server)
resource "azurerm_mssql_database" "this" {
  for_each = var.mssql_config.databases

  name                 = each.value.name
  server_id            = azurerm_mssql_server.primary.id
  max_size_gb          = each.value.max_size_gb
  sku_name             = each.value.sku_name
  collation            = each.value.collation
  license_type         = each.value.license_type
  read_scale           = each.value.read_scale
  zone_redundant       = each.value.zone_redundant
  ledger_enabled       = each.value.ledger_enabled
  storage_account_type = each.value.storage_account_type

  read_replica_count = (
    each.value.sku_name == "Hyperscale" && each.value.read_replica_count != null
  ) ? each.value.read_replica_count : null

  dynamic "short_term_retention_policy" {
    for_each = each.value.short_term_retention_policy != null ? [each.value.short_term_retention_policy] : []
    content {
      retention_days           = short_term_retention_policy.value.retention_days
      backup_interval_in_hours = short_term_retention_policy.value.backup_interval_in_hours
    }
  }

  dynamic "long_term_retention_policy" {
    for_each = each.value.long_term_retention_policy != null ? [each.value.long_term_retention_policy] : []
    content {
      weekly_retention  = long_term_retention_policy.value.weekly_retention
      monthly_retention = long_term_retention_policy.value.monthly_retention
      yearly_retention  = long_term_retention_policy.value.yearly_retention
      week_of_year      = long_term_retention_policy.value.week_of_year
    }
  }

  dynamic "threat_detection_policy" {
    for_each = each.value.threat_detection_policy != null ? [each.value.threat_detection_policy] : []
    content {
      state                      = threat_detection_policy.value.state
      disabled_alerts            = threat_detection_policy.value.disabled_alerts
      email_account_admins       = threat_detection_policy.value.email_account_admins
      email_addresses            = threat_detection_policy.value.email_addresses
      retention_days             = threat_detection_policy.value.retention_days
      storage_account_access_key = threat_detection_policy.value.storage_account_access_key
      storage_endpoint           = threat_detection_policy.value.storage_endpoint
    }
  }

  #  Only assign if set — this is a scalar, no dynamic needed
  transparent_data_encryption_enabled = each.value.transparent_data_encryption_enabled

  transparent_data_encryption_key_vault_key_id = (
    each.value.transparent_data_encryption_key_vault_key_id != null &&
    each.value.transparent_data_encryption_key_automatic_rotation_enabled != null
  ) ? each.value.transparent_data_encryption_key_vault_key_id : null

  transparent_data_encryption_key_automatic_rotation_enabled = (
    each.value.transparent_data_encryption_key_vault_key_id != null &&
    each.value.transparent_data_encryption_key_automatic_rotation_enabled != null
  ) ? each.value.transparent_data_encryption_key_automatic_rotation_enabled : null

  tags = each.value.tags
}

resource "azurerm_mssql_database_extended_auditing_policy" "this" {
  for_each = { for db_name, db in var.mssql_config.databases : db_name => db if db.extended_auditing_policy != null }

  database_id                = azurerm_mssql_database.this[each.key].id
  storage_endpoint           = each.value.extended_auditing_policy.storage_endpoint
  storage_account_access_key = each.value.extended_auditing_policy.storage_account_access_key
  retention_in_days          = each.value.extended_auditing_policy.retention_in_days
  log_monitoring_enabled     = each.value.extended_auditing_policy.log_monitoring_enabled
}

# FAILOVER GROUP (If enabled)
resource "azurerm_mssql_failover_group" "this" {
  count     = var.mssql_config.server.enable_failover_group ? 1 : 0
  name      = var.mssql_config.server.failover_group_name
  server_id = azurerm_mssql_server.primary.id
  databases = [for db in azurerm_mssql_database.this : db.id]

  partner_server {
    id = azurerm_mssql_server.secondary[0].id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }

  tags = var.mssql_config.server.tags
}

resource "azurerm_role_assignment" "sql_tde_key_access" {
  count                = var.key_vault_id != null ? 1 : 0
  principal_id         = azurerm_mssql_server.primary.identity[0].principal_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  scope                = var.key_vault_id
}
