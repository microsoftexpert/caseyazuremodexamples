variable "web_app_config" {
  description = "Configuration for a Linux Web App with Docker-based deployment, slots, identity, TLS, VNet integration, logging, and zero-downtime deployment strategies."

  type = object({
    name                = string
    location            = string
    resource_group_name = string
    service_plan_id     = string
    https_only          = optional(bool)
    tags                = optional(map(string), {})

    zip_deploy_file = optional(string)
    virtual_network_subnet_id = optional(string)

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))

    client_cert_enabled = optional(bool)
    client_cert_mode    = optional(string)

    site_config = object({
      linux_fx_version         = string
      always_on                = optional(bool)
      http2_enabled            = optional(bool)
      min_tls_version          = optional(string)
      scm_minimum_tls_version = optional(string)
      health_check_path        = optional(string)
      ftps_state               = optional(string)
      remote_debugging_enabled = optional(bool)
      scm_type                 = optional(string)
      websockets_enabled       = optional(bool)

      app_settings = optional(map(string))

      connection_strings = optional(list(object({
        name  = string
        type  = string
        value = string
      })))
    })

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

    slots = optional(map(object({
      site_config = object({
        linux_fx_version         = string
        always_on                = optional(bool)
        min_tls_version          = optional(string)
        health_check_path        = optional(string)
        app_settings             = optional(map(string))
        connection_strings       = optional(list(object({
          name  = string
          type  = string
          value = string
        })))
      })

      sticky_settings = optional(object({
        app_setting_names       = optional(list(string))
        connection_string_names = optional(list(string))
      }))
    })))
  })

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned"], lookup(var.web_app_config.identity, "type", "SystemAssigned"))
    error_message = "identity.type must be 'SystemAssigned' or 'UserAssigned'."
  }

  validation {
    condition     = var.web_app_config.client_cert_enabled == false || contains(["Required", "Optional"], var.web_app_config.client_cert_mode)
    error_message = "If client_cert_enabled is true, client_cert_mode must be 'Required' or 'Optional'."
  }

  validation {
    condition     = var.web_app_config.virtual_network_subnet_id == null || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", var.web_app_config.virtual_network_subnet_id))
    error_message = "virtual_network_subnet_id must be a valid subnet resource ID if specified."
  }

  validation {
    condition     = var.web_app_config.slots == null || alltrue([for k, v in var.web_app_config.slots : can(v.site_config.linux_fx_version)])
    error_message = "Each slot must have a valid site_config.linux_fx_version defined."
  }
}
