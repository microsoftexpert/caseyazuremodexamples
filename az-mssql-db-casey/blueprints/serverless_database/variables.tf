variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region where resources will be deployed."
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
  description = "The name of the resource group for the MSSQL Server."
  type        = string
}

variable "create_resource_group" {
  description = "Whether to create the resource group if it does not exist."
  type        = bool
  default     = false
}

variable "server_name" {
  description = "The name of the Azure SQL Server."
  type        = string
}

variable "admin_login" {
  description = "Administrator username for SQL Server."
  type        = string
}

variable "admin_password" {
  description = "Administrator password for SQL Server."
  type        = string
  sensitive   = true
}

variable "enable_monitoring" {
  description = "Enable monitoring and diagnostics for MSSQL Server."
  type        = bool
  default     = true
}

variable "enable_threat_detection" {
  description = "Enable threat detection on the MSSQL Server."
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Azure Log Analytics Workspace ID for monitoring. Required if monitoring is enabled."
  type        = string
  default     = null
}

variable "key_vault_id" {
  description = "Azure Key Vault resource ID for Transparent Data Encryption with CMK."
  type        = string
  default     = null
}

variable "azuread_login_username" {
  description = "Azure AD administrator login username (e.g., user@domain.com or AAD group name)."
  type        = string
}

variable "azuread_object_id" {
  description = "Azure AD object ID for the administrator (user or group)."
  type        = string
}

variable "databases" {
  description = "A map of serverless databases to be created in the MSSQL Server."
  type = map(object({
    name                               = string
    sku_name                           = optional(string, "GP_S_Gen5_2")
    auto_pause_delay_in_minutes        = optional(number, 60)
    min_capacity                       = optional(number, 0.5)
    max_size_gb                        = optional(number, 32)
    collation                          = optional(string, "SQL_Latin1_General_CP1_CI_AS")

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
      state                  = string
      email_account_admins   = optional(bool, true)
      email_addresses        = optional(list(string), [])
    }))

    extended_auditing_policy = optional(object({
      storage_endpoint           = string
      storage_account_access_key = optional(string)
      retention_in_days          = optional(number, 30)
    }))

    transparent_data_encryption_enabled                          = optional(bool, true)
    transparent_data_encryption_key_vault_key_id                 = optional(string)
    transparent_data_encryption_key_automatic_rotation_enabled   = optional(bool, false)
    prevent_destroy                                              = optional(bool, true)
    tags                                                         = optional(map(string), {})
  }))
}

variable "tags" {
  description = "Tags to assign to all deployed resources."
  type        = map(string)
  default     = {}
}
