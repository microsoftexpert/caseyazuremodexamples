variable "web_app_config" {
  description = "Configuration for a Linux Web App deployed with high availability settings."

  type = object({
    name                = string
    location            = string
    resource_group_name = string
    service_plan_id     = string
    tags                = optional(map(string), {})

    virtual_network_subnet_id = optional(string)

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))

    site_config = optional(object({
      always_on                = optional(bool)
      min_tls_version          = optional(string)
      scm_minimum_tls_version  = optional(string)
      ftps_state               = optional(string)
      http2_enabled            = optional(bool)
      linux_fx_version         = optional(string)
      health_check_path        = optional(string)
      remote_debugging_enabled = optional(bool)
      scm_type                 = optional(string)
      websockets_enabled       = optional(bool)
      app_settings             = optional(map(string))
      connection_strings       = optional(list(object({
        name  = string
        type  = string
        value = string
      })))
    }), null)

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

    backup = optional(object({
      enabled             = bool
      storage_account_url = string
      schedule = object({
        frequency_interval        = number
        frequency_unit            = string
        keep_at_least_one_backup = optional(bool)
        retention_period_in_days  = optional(number)
        start_time                = optional(string)
      })
    }))
  })

  validation {
    condition     = var.web_app_config.name != ""
    error_message = "Web App name must not be empty."
  }

  validation {
    condition     = var.web_app_config.service_plan_id != ""
    error_message = "You must provide a service_plan_id for deployment."
  }

  validation {
    condition     = var.web_app_config.identity == null || contains(["SystemAssigned", "UserAssigned"], var.web_app_config.identity.type)
    error_message = "identity.type must be either 'SystemAssigned' or 'UserAssigned'."
  }

  validation {
    condition     = var.web_app_config.site_config == null || try(var.web_app_config.site_config.always_on != null, false)
    error_message = "You should enable always_on in site_config for production HA workloads."
  }

  validation {
    condition     = var.web_app_config.site_config == null || try(var.web_app_config.site_config.min_tls_version != null, false)
    error_message = "site_config.min_tls_version must be specified to ensure TLS enforcement."
  }

  validation {
    condition     = var.web_app_config.virtual_network_subnet_id == null || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", var.web_app_config.virtual_network_subnet_id))
    error_message = "virtual_network_subnet_id must be a valid Azure subnet resource ID if provided."
  }
}
