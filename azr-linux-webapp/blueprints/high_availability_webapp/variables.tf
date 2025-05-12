variable "web_app_config" {
  description = "Config for high-availability Web App with observability and healing."
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    tags                = optional(map(string), {})

    service_plan = object({
      name                            = string
      location                        = string
      resource_group_name             = string
      os_type                         = string
      sku_name                        = string
      zone_balancing_enabled          = optional(bool)
      worker_count                    = optional(number)
    })

    https_only = optional(bool)

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))

    site_config = object({
      always_on               = optional(bool)
      linux_fx_version        = optional(string)
      number_of_workers       = optional(number)
      health_check_path       = optional(string)
      minimum_tls_version     = optional(string)
      scm_minimum_tls_version = optional(string)
      auto_heal_enabled       = optional(bool)

      auto_heal_setting = optional(object({
        triggers = object({
          slow_request = optional(object({
            count      = number
            time_taken = string
            path       = optional(string)
          }))
        })
        actions = object({
          action_type                   = string
          minimum_process_execution_time = optional(string)
        })
      }))
    })

    zip_deploy_file = optional(string)

    auth_settings = optional(object({
      enabled                        = bool
      issuer                         = string
      default_provider               = string
      unauthenticated_client_action  = optional(string)
      token_store_enabled            = optional(bool)
      active_directory = optional(object({
        client_id                   = string
        client_secret_setting_name = string
        allowed_audiences          = list(string)
      }))
    }))

    virtual_network_subnet_id = optional(string)

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
      application_insights_key = optional(string)
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

    ip_restriction = optional(list(object({
      name       = string
      priority   = number
      action     = string
      ip_address = optional(string)
      service_tag = optional(string)
      virtual_network_subnet_id = optional(string)
      headers = optional(object({
        x_forwarded_for    = optional(list(string))
        x_forwarded_host   = optional(list(string))
        x_fd_health_probe  = optional(list(string))
        x_azure_fdid       = optional(list(string))
      }))
    })))
  })
}
