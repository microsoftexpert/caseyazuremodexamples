variable "web_app_config" {
  description = "Configuration for a Linux Web App fronted by Azure CDN, with support for zip deployment, custom domain, identity, logging, and backup."
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    service_plan_id     = string
    https_only          = optional(bool)
    tags                = optional(map(string), {})

    site_config = optional(object({
      always_on               = optional(bool)
      minimum_tls_version     = optional(string)
      scm_minimum_tls_version = optional(string)
      ftps_state              = optional(string)
      health_check_path       = optional(string)
      cors = optional(object({
        allowed_origins     = optional(list(string))
        support_credentials = optional(bool)
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
    }))

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))

    app_settings = optional(map(string))
    zip_deploy_file = optional(string)
    custom_domain_verification_id = optional(string)

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
        start_time               = string
      })
    }))
  })

  validation {
  condition     = var.web_app_config.identity == null || contains(["SystemAssigned", "UserAssigned"], var.web_app_config.identity.type)
  error_message = "identity.type must be either 'SystemAssigned' or 'UserAssigned'."
}

validation {
  condition     = var.web_app_config.custom_domain == null || can(regex("^[a-zA-Z0-9.-]+$", var.web_app_config.custom_domain))
  error_message = "custom_domain must be a valid domain name if specified."
}


  validation {
    condition     = var.web_app_config.name != ""
    error_message = "Web App name must not be empty."
  }

  validation {
    condition     = var.web_app_config.service_plan_id != ""
    error_message = "App Service Plan ID is required."
  }
}
