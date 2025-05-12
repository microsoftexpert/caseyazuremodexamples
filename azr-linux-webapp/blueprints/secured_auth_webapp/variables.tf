variable "web_app_config" {
  description = "Configuration for the secured Linux Web App with support for authentication, identity, CORS, IP restrictions, and optional VNet integration."

  type = object({
    name                = string
    resource_group_name = string
    location            = string
    service_plan_id     = string

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))

    site_config = optional(object({
      always_on                         = optional(bool)
      ftps_state                        = optional(string)
      http2_enabled                     = optional(bool)
      min_tls_version                   = optional(string)
      linux_fx_version                  = optional(string)
      client_certificate_exclusion_paths = optional(list(string))
      app_settings                      = optional(map(string))
    }))

    auth_settings_v2 = optional(object({
      auth_enabled           = optional(bool)
      require_authentication = optional(bool)
      unauthenticated_action = optional(string)
      default_provider       = optional(string)

      login = optional(object({
        token_store_enabled                = optional(bool)
        preserve_url_fragments_for_logins = optional(bool)
      }))

      active_directory = optional(object({
        client_id             = optional(string)
        tenant_auth_endpoint = optional(string)
      }))

      google = optional(object({
        client_id                  = optional(string)
        client_secret_setting_name = optional(string)
      }))

      facebook = optional(object({
        app_id                  = optional(string)
        app_secret_setting_name = optional(string)
      }))

      apple = optional(object({
        client_id                  = optional(string)
        client_secret_setting_name = optional(string)
      }))
    }))

    cors = optional(object({
      allowed_origins     = list(string)
      support_credentials = optional(bool)
    }))

    client_cert_enabled = optional(bool)
    client_cert_mode    = optional(string)

    ip_restriction = optional(list(object({
      name       = string
      ip_address = string
      action     = string
      priority   = number
      headers = optional(object({
        x_forwarded_for = optional(list(string))
        x_forwarded_host = optional(list(string))
      }))
    })))

    virtual_network_subnet_id = optional(string)
    tags                      = optional(map(string))
  })

  validation {
    condition     = can(regex("^(SystemAssigned|UserAssigned)$", lookup(var.web_app_config.identity, "type", "SystemAssigned")))
    error_message = "identity.type must be either 'SystemAssigned' or 'UserAssigned'."
  }

  validation {
    condition     = var.web_app_config.client_cert_enabled == false || contains(["Optional", "Required"], var.web_app_config.client_cert_mode)
    error_message = "If client_cert_enabled is true, client_cert_mode must be 'Optional' or 'Required'."
  }

  validation {
    condition     = length(var.web_app_config.ip_restriction) == 0 || alltrue([for ip in var.web_app_config.ip_restriction : can(ip.name) && can(ip.ip_address)])
    error_message = "Each ip_restriction entry must include 'name' and 'ip_address'."
  }

  validation {
    condition     = var.web_app_config.auth_settings_v2 == null || can(var.web_app_config.auth_settings_v2.login)
    error_message = "If auth_settings_v2 is used, a 'login' block must be defined."
  }

  validation {
    condition     = var.web_app_config.cors == null || length(var.web_app_config.cors.allowed_origins) > 0
    error_message = "CORS block must include at least one allowed origin."
  }

  validation {
    condition     = var.web_app_config.virtual_network_subnet_id == null || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", var.web_app_config.virtual_network_subnet_id))
    error_message = "virtual_network_subnet_id must be a valid Azure subnet resource ID if specified."
  }
}
