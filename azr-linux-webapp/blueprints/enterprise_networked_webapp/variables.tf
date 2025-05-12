variable "web_app_config" {
  description = "Configuration for an enterprise-secure Linux Web App with optional ASE, VNet, identity, IP filtering, logging, backup, and advanced runtime settings."

  type = object({
    name                = string
    location            = string
    resource_group_name = string
    service_plan_id     = string
    https_only          = optional(bool)
    tags                = optional(map(string), {})

    app_service_environment_id = optional(string)
    virtual_network_subnet_id  = optional(string)

    zip_deploy_file = optional(string)

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))

    site_config = optional(object({
      always_on                  = optional(bool)
      linux_fx_version           = optional(string)
      health_check_path          = optional(string)
      minimum_tls_version        = optional(string)
      scm_minimum_tls_version    = optional(string)
      ftps_state                 = optional(string)
      http2_enabled              = optional(bool)
      remote_debugging_enabled   = optional(bool)
      scm_type                   = optional(string)
      websockets_enabled         = optional(bool)
      app_settings               = optional(map(string))
      connection_strings         = optional(list(object({
        name  = string
        type  = string
        value = string
      })))
    }))

    ip_restriction = optional(list(object({
      name                      = string
      priority                  = number
      action                    = string
      ip_address                = optional(string)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
      headers = optional(object({
        x_azure_fdid        = optional(list(string))
        x_fd_health_probe   = optional(list(string))
        x_forwarded_for     = optional(list(string))
        x_forwarded_host    = optional(list(string))
      }))
    })))

    client_cert_enabled = optional(bool)
    client_cert_mode    = optional(string)

    auth_settings = optional(object({
      enabled                       = bool
      issuer                        = string
      default_provider              = string
      unauthenticated_client_action = optional(string)
      token_store_enabled           = optional(bool)
      active_directory = optional(object({
        client_id                   = string
        client_secret_setting_name = string
        allowed_audiences          = list(string)
      }))
    }))

    logs = optional(object({
      application_logs = optional(object({
        file_system_level = optional(string)
      }))
      http_logs = optional(object({
        file_system = optional(object({
          retention_in_mb   = optional(number)
          retention_in_days = optional(number)
        }))
      }))
    }))

    backup = optional(object({
      name                = string
      enabled             = bool
      storage_account_url = string
      schedule = object({
        frequency_interval        = number
        frequency_unit            = string
        keep_at_least_one_backup = bool
        retention_period_in_days = number
        start_time                = string
      })
    }))
  })

  validation {
    condition     = var.web_app_config.virtual_network_subnet_id != null && var.web_app_config.virtual_network_subnet_id != ""
    error_message = "You must specify a valid virtual_network_subnet_id for VNet integration."
  }

  validation {
    condition     = var.web_app_config.identity == null || contains(["SystemAssigned", "UserAssigned"], var.web_app_config.identity.type)
    error_message = "identity.type must be 'SystemAssigned' or 'UserAssigned'."
  }

  validation {
    condition     = var.web_app_config.client_cert_enabled == false || contains(["Required", "Optional"], var.web_app_config.client_cert_mode)
    error_message = "If client_cert_enabled is true, client_cert_mode must be 'Required' or 'Optional'."
  }

  validation {
    condition     = var.web_app_config.ip_restriction == null || alltrue([for ip in var.web_app_config.ip_restriction : can(ip.name) && (can(ip.ip_address) || can(ip.service_tag))])
    error_message = "Each ip_restriction entry must include either an ip_address or service_tag."
  }

  validation {
    condition     = var.web_app_config.app_service_environment_id == null || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Web/hostingEnvironments/.+$", var.web_app_config.app_service_environment_id))
    error_message = "app_service_environment_id must be a valid ASE resource ID if specified."
  }
}
