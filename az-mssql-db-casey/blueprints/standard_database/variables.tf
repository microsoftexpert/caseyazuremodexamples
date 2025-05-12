variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region where the MSSQL Server will be deployed."
  type        = string
  default     = "centralus"
}

variable "subscription_id" {
  description = "The Azure Subscription ID."
  type        = string
}

variable "tenant_id" {
  description = "The Azure Tenant ID."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to deploy the MSSQL Server."
  type        = string
}

variable "create_resource_group" {
  description = "Whether to create a new resource group if it does not exist."
  type        = bool
  default     = false
}

variable "server_name" {
  description = "The name of the Azure SQL Server."
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the Azure Key Vault used for TDE with CMK. Optional."
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "ID of the Azure Log Analytics workspace for monitoring. If not provided, monitoring will be disabled."
  type        = string
  default     = null
}

variable "enable_monitoring" {
  description = "Enable monitoring and diagnostic settings for MSSQL Server."
  type        = bool
  default     = true
}

variable "azuread_login_username" {
  description = "Azure AD login username for the SQL Server administrator."
  type        = string
}

variable "azuread_object_id" {
  description = "Azure AD Object ID for the SQL Server administrator."
  type        = string
}

variable "databases" {
  description = "A map of standard databases to be created."
  type = map(object({
    name                        = string
    sku_name                    = optional(string, "S0")
    max_size_gb                 = optional(number, 20)
    collation                   = optional(string, "SQL_Latin1_General_CP1_CI_AS")
    zone_redundant              = optional(bool, false)
    geo_backup_enabled          = optional(bool, false)
    storage_account_type        = optional(string, "LRS")
    create_mode                 = optional(string, "Default")
    restore_point_in_time       = optional(string)
    restore_dropped_database_id = optional(string)
    recover_database_id         = optional(string)
    prevent_destroy             = optional(bool, true)

    short_term_retention_policy = optional(object({
      retention_days           = number
      backup_interval_in_hours = optional(number, 12)
    }))

    long_term_retention_policy = optional(object({
      weekly_retention  = optional(string, "P1W")
      monthly_retention = optional(string, "P1M")
      yearly_retention  = optional(string, "P1Y")
      week_of_year      = optional(number)
    }))

    threat_detection_policy = optional(object({
      state                   = string
      disabled_alerts         = optional(list(string))
      email_account_admins    = optional(bool)
      email_addresses         = optional(list(string))
      retention_days          = optional(number)
      storage_account_access_key = optional(string)
      storage_endpoint        = optional(string)
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
    tags                                                       = optional(map(string), {})
  }))
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
