variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region where the primary MSSQL Server will be deployed."
  type        = string
  default     = "centralus"
}

variable "secondary_location" {
  description = "Azure region for the geo-redundant secondary MSSQL Server."
  type        = string

  validation {
    condition     = var.secondary_location != null
    error_message = "Secondary location must be specified for failover group scenarios."
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

variable "resource_group_name" {
  description = "The name of the resource group in which to deploy the geo-redundant database."
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

variable "failover_group_name" {
  description = "The name of the failover group for automatic failover."
  type        = string
  default     = "mssql-failover-group"
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
  description = "Enable monitoring and logging for MSSQL Server."
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostics. Required if monitoring is enabled."
  type        = string
  default     = null
}

variable "key_vault_id" {
  description = "Azure Key Vault resource ID for Transparent Data Encryption with CMK."
  type        = string
  default     = null
}

variable "azuread_login_username" {
  description = "Azure AD administrator login username (user or group name)."
  type        = string
}

variable "azuread_object_id" {
  description = "Azure AD object ID for the administrator (user or group)."
  type        = string
}

variable "databases" {
  description = "A map of geo-redundant databases to be created."
  type = map(object({
    name                      = string
    sku_name                  = optional(string, "BC_Gen5_2")
    max_size_gb               = optional(number, 32)
    collation                 = optional(string, "SQL_Latin1_General_CP1_CI_AS")
    zone_redundant            = optional(bool, true)
    geo_backup_enabled        = optional(bool, true)
    failover_group_enabled    = optional(bool, true)
    secondary_location        = optional(string)
    prevent_destroy           = optional(bool, true)
    tags                      = optional(map(string), {})
  }))
}

variable "tags" {
  description = "Tags to assign to all deployed resources."
  type        = map(string)
  default     = {}
}
