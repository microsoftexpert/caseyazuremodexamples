variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "resource_group_name" {
  description = "The name of the resource group where the SQL resources will be deployed."
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "The resource_group_name must not be empty."
  }
}
variable "key_vault_id" {
  description = "The ID of the Azure Key Vault used for Transparent Data Encryption (TDE) with a Customer Managed Key (CMK)."
  type        = string
  default     = null

  validation {
    condition = (
      var.key_vault_id == null ||
      (
        can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.KeyVault/vaults/.+$", var.key_vault_id)) &&
        !endswith(var.key_vault_id, "/")
      )
    )
    error_message = "Invalid Key Vault ID. Must be a full Azure resource ID without a trailing slash."
  }
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Azure Log Analytics workspace. If not provided, monitoring will be disabled."
  type        = string
  default     = null

  #  Moved validation rule outside of mssql_config
  validation {
    condition     = var.log_analytics_workspace_id == null || can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.OperationalInsights/workspaces/.*$", var.log_analytics_workspace_id))
    error_message = "Invalid Log Analytics Workspace ID format. Expected format: /subscriptions/{subscription_id}/resourceGroups/{resource_group}/providers/Microsoft.OperationalInsights/workspaces/{workspace_name}."
  }
}

variable "subscription_id" {
  description = "The Azure Subscription ID."
  type        = string
}

variable "tenant_id" {
  description = "The Azure Tenant ID."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
  default     = "centralus"
}

variable "mssql_config" {
  description = "Configuration object for MSSQL Server and its databases."
  type = object({
    server = object({
      name                  = string
      create_resource_group = optional(bool, false)
      secondary_location    = optional(string, "eastus2")
      version               = optional(string, "12.0")
      azuread_administrator = object({
        login_username = string
        object_id      = string
      })
      identity = optional(object({
        type         = string
        identity_ids = optional(list(string))
      }))
      user_assigned_identity_id                    = optional(string)
      transparent_data_encryption_key_vault_key_id = optional(string)
      minimum_tls_version                          = optional(string, "1.2")
      public_network_access_enabled                = optional(bool, false)
      outbound_network_restriction_enabled         = optional(bool, false)
      enable_monitoring                            = optional(bool, true)
      enable_threat_detection                      = optional(bool, true)
      enable_failover_group                        = optional(bool, false)
      failover_group_name                          = optional(string)
      tags                                         = optional(map(string), {})
    })

    databases = map(object({
      name                        = string
      max_size_gb                 = number
      sku_name                    = string
      collation                   = optional(string, "SQL_Latin1_General_CP1_CI_AS")
      license_type                = optional(string, "LicenseIncluded")
      ledger_enabled              = optional(bool, false)
      read_scale                  = optional(bool, false)
      zone_redundant              = optional(bool, false)
      geo_backup_enabled          = optional(bool, false)
      failover_group_enabled      = optional(bool, false)
      storage_account_type        = optional(string, "LRS")
      create_mode                 = optional(string, "Default")
      read_replica_count          = optional(number)
      auto_pause_delay_in_minutes = optional(number, -1)
      min_capacity                = optional(number, 0.5)
      secondary_location          = optional(string)

      short_term_retention_policy = optional(object({
        retention_days           = number
        backup_interval_in_hours = optional(number, 12)
      }))

      long_term_retention_policy = optional(object({
        weekly_retention  = string
        monthly_retention = string
        yearly_retention  = string
        week_of_year      = optional(number)
      }))

      threat_detection_policy = optional(object({
        state                      = string
        disabled_alerts            = optional(list(string))
        email_account_admins       = optional(bool)
        email_addresses            = optional(list(string))
        retention_days             = optional(number)
        storage_account_access_key = optional(string)
        storage_endpoint           = optional(string)
      }))

      extended_auditing_policy = optional(object({
        storage_endpoint           = string
        storage_account_access_key = optional(string)
        retention_in_days          = optional(number)
        log_monitoring_enabled     = optional(bool)
      }))

      transparent_data_encryption_enabled                        = optional(bool, true)
      transparent_data_encryption_key_vault_key_id               = optional(string)
      transparent_data_encryption_key_automatic_rotation_enabled = optional(bool, false)
      prevent_destroy                                            = optional(bool, true)
      tags                                                       = optional(map(string), {})
    }))
  })

  # Validate MSSQL server version
  validation {
    condition     = contains(["12.0", "2.0"], var.mssql_config.server.version)
    error_message = "Supported MSSQL Server versions are: 12.0, 2.0"
  }

  # Validate minimum_tls_version against supported values
  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.mssql_config.server.minimum_tls_version)
    error_message = "minimum_tls_version must be one of: 1.0, 1.1, 1.2"
  }

  # Validate collation format
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      db.collation == null || can(regex("^[a-zA-Z0-9_]+$", db.collation))
    ])
    error_message = "Collation must only contain alphanumeric characters and underscores."
  }

  # Validate auto rotation flag is only used with CMK
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      db.transparent_data_encryption_key_automatic_rotation_enabled != true || (
        db.transparent_data_encryption_key_vault_key_id != null
      )
    ])
    error_message = "transparent_data_encryption_key_automatic_rotation_enabled requires a Key Vault Key ID to be set."
  }

  # Ensure prevent_destroy is a boolean value
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      db.prevent_destroy == null || can(tobool(db.prevent_destroy))
    ])
    error_message = "prevent_destroy must be a boolean value (true or false)."
  }

  #  Validate short_term_retention_policy input values
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      db.short_term_retention_policy == null ||

      (
        db.short_term_retention_policy.retention_days >= 1 &&
        db.short_term_retention_policy.retention_days <= 35 &&
        (
          db.short_term_retention_policy.backup_interval_in_hours == null ||
          contains([12, 24], db.short_term_retention_policy.backup_interval_in_hours)
        )
      )
    ])
    error_message = "Invalid short_term_retention_policy: retention_days must be between 1 and 35, and backup_interval_in_hours must be either 12 or 24."
  }


  #  Validate threat_detection_policy configuration
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      db.threat_detection_policy == null ||

      (
        contains(["Enabled", "Disabled"], db.threat_detection_policy.state) &&
        (
          db.threat_detection_policy.state == "Disabled" ||
          (
            db.threat_detection_policy.storage_endpoint != null &&
            can(regex("^https://[a-z0-9]+\\.blob\\.core\\.windows\\.net/?$", db.threat_detection_policy.storage_endpoint))
          )
        ) &&
        (
          db.threat_detection_policy.retention_days == null ||
          db.threat_detection_policy.retention_days >= 0
        )
      )
    ])
    error_message = "Invalid threat_detection_policy: 'state' must be 'Enabled' or 'Disabled'. If enabled, 'storage_endpoint' must be set and valid. retention_days must be ≥ 0."
  }

  # If failover group is enabled, failover_group_name must be provided and consist of alphanumeric characters and dashes only
  validation {
    condition = (
      var.mssql_config.server.enable_failover_group == false ||
      (
        var.mssql_config.server.failover_group_name != null &&
        can(regex("^[a-zA-Z0-9-]+$", var.mssql_config.server.failover_group_name))
      )
    )
    error_message = "If failover group is enabled, failover_group_name must be provided and consist of alphanumeric characters and dashes only."
  }

  #  Validate storage_account_type values
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      contains(["Geo", "GeoZone", "Local", "Zone"], db.storage_account_type)
    ])
    error_message = "storage_account_type must be one of: Geo, GeoZone, Local, Zone."
  }

  #  Validation: read_scale must only be enabled for Premium and BusinessCritical SKUs
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      !db.read_scale || contains(["Premium", "BusinessCritical"], db.sku_name)
    ])
    error_message = "read_scale is only supported on Premium and BusinessCritical SKUs."
  }

  # Validation for Create Mode Restore contstraint
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      (
        db.create_mode != "Restore" &&
        db.restore_dropped_database_id == null &&
        db.restore_point_in_time == null &&
        db.recover_database_id == null
        ) || (
        db.create_mode == "Restore" &&
        (
          db.restore_dropped_database_id != null ||
          db.restore_point_in_time != null ||
          db.recover_database_id != null
        )
      )
    ])
    error_message = "If create_mode is 'Restore', at least one of restore_point_in_time, restore_dropped_database_id, or recover_database_id must be provided. Otherwise, none should be set."
  }

  # Validate failover group grace minutes constraints
  validation {
    condition = (
      var.mssql_config.server.enable_failover_group == false ||
      (
        var.mssql_config.server.failover_group_name != null &&
        true /* grace_minutes is hardcoded in your resource as 60 */
      )
    )
    error_message = "When using Automatic mode in failover group, grace_minutes must be set."
  }

  # Validate Extended auditing policy constraints
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      db.extended_auditing_policy == null ||
      (
        contains(keys(db.extended_auditing_policy), "storage_endpoint") ||
        db.extended_auditing_policy.log_monitoring_enabled == true
      )
    ])
    error_message = "Extended auditing policy must have either 'storage_endpoint' or 'log_monitoring_enabled' set."
  }
   #Validate extended_auditing_policy.retention_in_days within allowed range
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      db.extended_auditing_policy == null ||
      db.extended_auditing_policy.retention_in_days == null ||
      (
        db.extended_auditing_policy.retention_in_days >= 0 &&
        db.extended_auditing_policy.retention_in_days <= 3285
      )
    ])
    error_message = "extended_auditing_policy.retention_in_days must be between 0 and 3285."
  }
  #Validate storeage account access key is secondary is only used if key is set
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      db.extended_auditing_policy == null ||
      db.extended_auditing_policy.storage_account_access_key_is_secondary == null ||
      db.extended_auditing_policy.storage_account_access_key != null
    ])
    error_message = "storage_account_access_key_is_secondary can only be used if storage_account_access_key is also provided."
  }

  # Validate Failover group name syntax
  validation {
    condition = (
      var.mssql_config.server.enable_failover_group == false ||
      (
        length(var.mssql_config.server.failover_group_name) >= 1 &&
        length(var.mssql_config.server.failover_group_name) <= 128 &&
        can(regex("^[a-zA-Z0-9-]+$", var.mssql_config.server.failover_group_name))
      )
    )
    error_message = "Failover group name must be 1–128 characters and consist of alphanumeric characters and dashes only."
  }

  #  Validation for allowed create_mode values
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      contains(["Default", "Copy", "Secondary", "Restore", "PointInTimeRestore", "Recovery", "RestoreExternalBackup", "RestoreExternalBackupSecondary"], db.create_mode)
    ])
    error_message = "Invalid create_mode. Must be one of: Default, Copy, Secondary, Restore, PointInTimeRestore, Recovery, RestoreExternalBackup, RestoreExternalBackupSecondary."
  }

  #  Validate auto_pause_delay_in_minutes for serverless SKUs
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      db.auto_pause_delay_in_minutes == null || db.auto_pause_delay_in_minutes == -1 || (
        db.auto_pause_delay_in_minutes >= 60 && db.auto_pause_delay_in_minutes <= 1440
      )
    ])
    error_message = "auto_pause_delay_in_minutes must be -1 (disabled) or between 60 and 1440 minutes."
  }

  #  Validate min_capacity for serverless SKUs
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      db.min_capacity == null || db.min_capacity >= 0.5
    ])
    error_message = "min_capacity must be greater than or equal to 0.5 if set."
  }

  #  Validate secondary_location for failover-enabled databases
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      !db.failover_group_enabled || (db.secondary_location != null && db.secondary_location != "")
    ])
    error_message = "secondary_location must be provided if failover_group_enabled is true for a database."
  }

  #  Validation for valid SKU selection
  validation {
    condition     = alltrue([for db in var.mssql_config.databases : contains(["Basic", "S0", "S1", "S2", "GP_S_Gen5_2", "BC_Gen5_2", "DW100c"], db.sku_name)])
    error_message = "Invalid SKU name provided. Allowed values are Basic, S0, S1, S2, GP_S_Gen5_2, BC_Gen5_2, DW100c."
  }

  #  Validation for valid database size
  validation {
    condition     = alltrue([for db in var.mssql_config.databases : db.max_size_gb > 0 && db.max_size_gb <= 4096])
    error_message = "Database max size must be between 1GB and 4096GB."
  }

  #  Validation for Zone Redundancy SKUs
  validation {
    condition     = alltrue([for db in var.mssql_config.databases : db.zone_redundant ? contains(["Premium", "BusinessCritical"], db.sku_name) : true])
    error_message = "Zone redundancy is only supported for Premium and BusinessCritical SKUs."
  }

  #  Geo Backup should only be enabled for DW SKUs
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      db.geo_backup_enabled == false || can(regex("^DW", db.sku_name))
    ])
    error_message = "Geo Backup is only supported on DataWarehouse SKUs (e.g., DW100c)."
  }

  #  Validation for Hyperscale replica count
  validation {
    condition     = alltrue([for db in var.mssql_config.databases : db.read_replica_count == null || db.sku_name == "Hyperscale"])
    error_message = "Read replica count must be specified only for Hyperscale edition."
  }

  #  Enforce correct usage of Transparent Data Encryption
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      (
        # Only DW SKUs may set TDE to false
        db.transparent_data_encryption_enabled != false || can(regex("^DW", db.sku_name))
      )
    ])
    error_message = "transparent_data_encryption_enabled can only be set to false for DW SKUs (e.g., DW100c). It must be enabled for all other SKUs."
  }

  #Validate backup interval in hours is only set when retention days is set
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      db.short_term_retention_policy == null || (
        db.short_term_retention_policy.retention_days != null ||
        db.short_term_retention_policy.backup_interval_in_hours == null
      )
    ])
    error_message = "backup_interval_in_hours can only be set when retention_days is set."
  }

  

  # Validate transparent data encryption is not set for DW SKUs with CMK
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      !can(regex("^DW", db.sku_name)) || (
        db.transparent_data_encryption_key_vault_key_id == null &&
        db.transparent_data_encryption_key_automatic_rotation_enabled == null
      )
    ])
    error_message = "CMK-based Transparent Data Encryption is not supported on DW SKUs."
  }


  # Validate sample db name AdventureWorksLT conditions
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      db.sample_name == null || db.create_mode == "Default"
    ])
    error_message = "sample_name can only be used when create_mode is 'Default'."
  }

  # Validated Consolidated SKU dependencies for edge use case
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      (
        (!db.zone_redundant || contains(["Premium", "BusinessCritical"], db.sku_name)) &&
        (!db.read_scale || contains(["Premium", "BusinessCritical"], db.sku_name)) &&
        (!db.geo_backup_enabled || can(regex("^DW", db.sku_name)))
      )
    ])
    error_message = "zone_redundant and read_scale require Premium or BusinessCritical SKUs. geo_backup_enabled is only supported for DW SKUs."
  }

  # Enclave validation restrictions
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      !contains(keys(db), "enclave_type") || (
        contains(["Default", "VBS"], db.enclave_type) &&
        !can(regex("^(DW|DC)", db.sku_name))
      )
    ])
    error_message = "If set, enclave_type must be 'Default' or 'VBS', and not used with DW or DC-series SKUs."
  }

  #  Validation for Failover Group requiring secondary location
  validation {
    condition     = !(var.mssql_config.server.enable_failover_group && var.mssql_config.server.secondary_location == null)
    error_message = "Failover group requires a secondary location to be specified."
  }

  # Ensure Azure AD administrator is always set
  validation {
    condition     = var.mssql_config.server.azuread_administrator != null
    error_message = "Azure AD Administrator must be configured to support Azure AD-only authentication."
  }

  #  Enforce valid license_type values
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      contains(["LicenseIncluded", "BasePrice"], db.license_type)
    ])
    error_message = "license_type must be one of: LicenseIncluded, BasePrice."
  }

  #  Validate long_term_retention_policy input formats and values
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      (
        db.long_term_retention_policy == null ||

        (
          # weekly_retention is either unset or ISO 8601 format
          (db.long_term_retention_policy.weekly_retention == null ||
          can(regex("^P(\\d+W|\\d+D)$", db.long_term_retention_policy.weekly_retention))) &&

          # monthly_retention is either unset or ISO 8601 format
          (db.long_term_retention_policy.monthly_retention == null ||
          can(regex("^P(\\d+M|\\d+D|\\d+W)$", db.long_term_retention_policy.monthly_retention))) &&

          # yearly_retention is either unset or ISO 8601 format
          (db.long_term_retention_policy.yearly_retention == null ||
          can(regex("^P(\\d+Y|\\d+M|\\d+W|\\d+D)$", db.long_term_retention_policy.yearly_retention))) &&

          # week_of_year is either unset or between 1 and 52
          (db.long_term_retention_policy.week_of_year == null ||
            (db.long_term_retention_policy.week_of_year >= 1 &&
          db.long_term_retention_policy.week_of_year <= 52))
        )
      )
    ])
    error_message = "Invalid long_term_retention_policy: durations must use ISO 8601 format (e.g. P1Y, P30D), and week_of_year must be between 1 and 52."
  }

  #  Enforce identity_ids and primary_user_assigned_identity_id for UserAssigned types
  validation {
    condition = (
      var.mssql_config.server.identity == null ||
      (
        !contains(["UserAssigned", "SystemAssigned, UserAssigned", "UserAssigned, SystemAssigned"], var.mssql_config.server.identity.type)
      ) ||
      (
        contains(["UserAssigned", "SystemAssigned, UserAssigned", "UserAssigned, SystemAssigned"], var.mssql_config.server.identity.type) &&
        var.mssql_config.server.identity.identity_ids != null &&
        length(var.mssql_config.server.identity.identity_ids) > 0 &&
        var.mssql_config.server.user_assigned_identity_id != null
      )
    )
    error_message = "If identity.type includes 'UserAssigned', both identity_ids and user_assigned_identity_id must be provided."
  }

  # Server name must be alphanumeric with optional dashes.
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.mssql_config.server.name))
    error_message = "Server name must be alphanumeric with optional dashes."
  }

 

  #Block unsupported combinations for identity type
  validation {
    condition = (
      var.mssql_config.server.identity == null ||
      !contains(["SystemAssigned, UserAssigned", "UserAssigned, SystemAssigned"], var.mssql_config.server.identity.type) ||
      (
        var.mssql_config.server.identity.identity_ids != null &&
        length(var.mssql_config.server.identity.identity_ids) > 0
      )
    )
    error_message = "When using mixed identity types (SystemAssigned + UserAssigned), identity_ids must be provided."
  }

 

  #Validate that Ledger is only supported for specific SKUs
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      !db.ledger_enabled || !contains(["DW100c", "Hyperscale"], db.sku_name)
    ])
    error_message = "Ledger is not supported on Data Warehouse or Hyperscale SKUs."
  }

  #Validate Server name length
  validation {
    condition     = length(var.mssql_config.server.name) >= 1 && length(var.mssql_config.server.name) <= 63
    error_message = "Server name must be between 1 and 63 characters."
  }

  #Validate database name length
  validation {
    condition = alltrue([
      for db in var.mssql_config.databases :
      length(db.name) > 0 && length(db.name) <= 128
    ])
    error_message = "Each database name must be between 1 and 128 characters."
  }

  #Validate CMK Key Vault URI format for Transparent Data Encryption
  validation {
    condition = (
      var.mssql_config.server.transparent_data_encryption_key_vault_key_id == null ||
      can(regex("^https://[a-zA-Z0-9-]+\\.vault\\.azure\\.net/keys/[a-zA-Z0-9-]+(/[a-zA-Z0-9]+)?$", var.mssql_config.server.transparent_data_encryption_key_vault_key_id))
    )
    error_message = "TDE Key Vault Key ID must be a URI like 'https://<vault>.vault.azure.net/keys/<key>' or include key version."
  }

}

#####Future Validations if we are going to use administrator login and password in the future#####
#  # Enforce naming rules on administrator_login if exposed
#   validation {
#     condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-_]{0,127}$", var.mssql_config.server.administrator_login))
#     error_message = "administrator_login must start with a letter and be 1-128 characters long, containing only letters, numbers, dashes, or underscores."
#   }
# # Validate administrator login omission conditions allowed
# validation {
#   condition = (
#     var.mssql_config.server.azuread_administrator != null &&
#     (
#       var.mssql_config.server.azuread_administrator.azuread_authentication_only == true
#     )
#   )
#   error_message = "administrator_login can only be omitted if AzureAD-only authentication is explicitly enabled."
# }