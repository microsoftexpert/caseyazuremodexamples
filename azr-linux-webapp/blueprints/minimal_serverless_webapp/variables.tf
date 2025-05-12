variable "web_app_config" {
  description = "Configuration for a flexible Linux Web App that supports minimal and serverless workloads."
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    service_plan_id     = string
    https_only          = optional(bool)
    tags                = optional(map(string), {})

    site_config = optional(object({
      always_on        = optional(bool)
      linux_fx_version = optional(string)       # e.g., "PYTHON|3.11", "NODE|18-lts"
      use_32_bit_worker_process = optional(bool)
      websockets_enabled         = optional(bool)
      remote_debugging_enabled   = optional(bool)
      remote_debugging_version   = optional(string)
      minimum_tls_version        = optional(string)
      ftps_state                 = optional(string)
      auto_heal_enabled          = optional(bool)
      auto_heal_setting = optional(object({
        trigger = object({
          private_bytes_in_kb = optional(number)
        })
        action = object({
          action_type = string
        })
      }))
    }))

    zip_deploy_file = optional(string)

    app_settings = optional(map(string))

    storage_connection_string = optional(string) # Used by Azure Functions

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))

    auth_settings = optional(object({
      enabled                        = bool
      issuer                         = string
      default_provider               = string
      unauthenticated_client_action  = optional(string)
      token_store_enabled            = optional(bool)
      active_directory = optional(object({
        client_id                   = string
        client_secret_setting_name = optional(string)
        allowed_audiences          = optional(list(string))
      }))
    }))

    logs = optional(object({
      application_logs = optional(object({
        file_system_level = optional(string)
      }))
      http_logs = optional(object({
        file_system = optional(object({
          retention_in_days = optional(number)
          retention_in_mb   = optional(number)
        }))
      }))
    }))

    ip_restrictions = optional(list(object({
      name     = string
      priority = number
      ip_address = optional(string)
      service_tag = optional(string)
      headers = optional(object({
        x_azure_fdid      = optional(list(string))
        x_fd_health_probe = optional(list(string))
        x_forwarded_for   = optional(list(string))
        x_forwarded_host  = optional(list(string))
      }))
    })))

    backup = optional(object({
      name                = string
      storage_account_url = string
      schedule = object({
        frequency_interval       = number
        frequency_unit           = string
        keep_at_least_one_backup = bool
        retention_period_in_days = number
        start_time               = string
      })
    }))
  })

  validation {
    condition     = can(regex("^linuxwebapp-", var.web_app_config.name))
    error_message = "Web app name must start with 'linuxwebapp-'."
  }

  validation {
    condition     = contains(["F1", "B1", "P1v2", "P2v2", "Y1", "EP1"], split("_", var.web_app_config.service_plan_id)[0])
    error_message = "Service plan SKU must be a valid App Service SKU for Linux (e.g., F1, B1, P1v2, Y1, EP1)."
  }

  validation {
    condition     = var.web_app_config.site_config == null || (
      var.web_app_config.site_config.minimum_tls_version == null ||
      contains(["1.0", "1.1", "1.2"], var.web_app_config.site_config.minimum_tls_version)
    )
    error_message = "Minimum TLS version must be one of: 1.0, 1.1, 1.2"
  }
}
