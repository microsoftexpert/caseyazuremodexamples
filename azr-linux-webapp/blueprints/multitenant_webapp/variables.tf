variable "web_app_config" {
  description = "Configuration for a multi-tenant Linux Web App."

  type = object({
    name                = string
    location            = string
    resource_group_name = string
    service_plan_id     = string
    https_only          = optional(bool)
    tags                = optional(map(string), {})

    site_config = object({
      always_on         = optional(bool)
      linux_fx_version  = optional(string)
      health_check_path = optional(string)
      min_tls_version   = optional(string)
      scm_minimum_tls_version = optional(string)
      app_settings      = optional(map(string))
      connection_strings = optional(list(object({
        name  = string
        type  = string
        value = string
      })))
    })

    auth_settings_v2 = optional(object({
      auth_enabled = bool
      active_directory_v2 = optional(list(object({
        client_id                  = string
        tenant_auth_endpoint       = string
        client_secret_setting_name = string
        jwt_allowed_groups         = optional(list(string))
      })))
    }))

    ip_restriction = optional(list(object({
      name       = string
      priority   = number
      action     = string
      ip_address = optional(string)
      headers = optional(object({
        x_forwarded_for = optional(list(string))
      }))
    })))

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
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

    zip_deploy_file = optional(string)

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

  ### ✅ Validations

  validation {
    condition     = var.web_app_config.name != ""
    error_message = "Web App name must not be empty."
  }

  validation {
    condition     = var.web_app_config.service_plan_id != ""
    error_message = "You must provide a valid service_plan_id."
  }

  validation {
    condition     = var.web_app_config.site_config != null
    error_message = "site_config must be provided."
  }

  validation {
    condition     = var.web_app_config.identity == null || contains(["SystemAssigned", "UserAssigned"], var.web_app_config.identity.type)
    error_message = "identity.type must be either 'SystemAssigned' or 'UserAssigned'."
  }

  validation {
    condition     = var.web_app_config.site_config == null || try(var.web_app_config.site_config.min_tls_version != null, false)
    error_message = "min_tls_version should be provided to enforce secure TLS for multitenant workloads."
  }
}
