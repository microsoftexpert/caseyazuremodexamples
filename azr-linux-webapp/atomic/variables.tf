variable "tags" {
  type        = map(string)
  description = "Optional tags to apply to resources"
  default     = {}
}

variable "web_app_config" {
  description = "Configuration object for the Azure Linux Web App and its optional slots."
  type = object({
    # Mandatory base settings
    name                = string
    resource_group_name = string
    location            = string
    zip_deploy_file     = optional(string)
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
    service_plan = optional(object({
      name                            = string
      location                        = string
      resource_group_name             = string
      os_type                         = string
      sku_name                        = string
      app_service_environment_id      = optional(string)
      per_site_scaling_enabled        = optional(bool)
      zone_balancing_enabled          = optional(bool)
      maximum_elastic_worker_count    = optional(number)
      worker_count                    = optional(number)
      premium_plan_auto_scale_enabled = optional(bool)

    }))

    sticky_settings = optional(object({
      app_setting_names       = optional(list(string))
      connection_string_names = optional(list(string))
    }))

    # Site configuration (required block, with optional fields)
    site_config = object({
      always_on                                     = optional(bool)
      linux_fx_version                              = optional(string)
      number_of_workers                             = optional(number)
      ftps_state                                    = optional(string)
      auto_heal_enabled                             = optional(bool)
      health_check_path                             = optional(string)
      minimum_tls_version                           = optional(string)
      scm_minimum_tls_version                       = optional(string)
      remote_debugging_enabled                      = optional(bool)
      remote_debugging_version                      = optional(string)
      websockets_enabled                            = optional(bool)
      vnet_route_all_enabled                        = optional(bool)
      managed_pipeline_mode                         = optional(string)
      load_balancing_mode                           = optional(string)
      app_command_line                              = optional(string)
      container_registry_use_managed_identity       = optional(bool)
      container_registry_managed_identity_client_id = optional(string)
      scm_use_main_ip_restriction                   = optional(bool)
      client_certificate_mode                       = optional(string)
      auto_heal                                     = optional(bool)
      health_check_eviction_time_in_min             = optional(number)
      api_definition_url                            = optional(string)
      api_management_api_id                         = optional(string)
      ip_restriction_default_action                 = optional(string)
      scm_ip_restriction_default_action             = optional(string)
      default_documents                             = optional(list(string))
      http2_enabled                                 = optional(bool)
      use_32_bit_worker                             = optional(bool)
      auto_swap_slot_name                           = optional(string)

      cors = optional(object({
        allowed_origins     = optional(list(string))
        support_credentials = optional(bool)
      }))
      application_stack = optional(object({
        docker_image_name           = optional(string)
        docker_registry_url         = optional(string)
        docker_registry_username    = optional(string)
        python_version              = optional(string)
        node_version                = optional(string)
        dotnet_version              = optional(string)
        java_version                = optional(string)
        java_server                 = optional(string)
        java_server_version         = optional(string)
        php_version                 = optional(string)
        ruby_version                = optional(string)
        go_version                  = optional(string)
        use_dotnet_isolated_runtime = optional(bool)
      }))

      auto_heal_setting = optional(object({
        triggers = optional(object({
          slow_request = optional(object({
            count      = number
            interval   = string
            time_taken = string
          }))
          status_code = optional(list(object({
            status_code_range = string
            count             = number
            interval          = string
            path              = optional(string)
            sub_status        = optional(string)
            win32_status_code = optional(string)
          })))
          requests = optional(object({
            count    = number
            interval = string
          }))
        }))
        actions = optional(object({
          action_type                    = string
          minimum_process_execution_time = optional(string)
        }))
      }))
      scm_ip_restriction = optional(list(object({
        name                      = optional(string)
        ip_address                = optional(string)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
        action                    = optional(string)
        priority                  = optional(number)
        headers = optional(object({
          x_forwarded_for   = optional(list(string))
          x_forwarded_host  = optional(list(string))
          x_azure_fdid      = optional(string) #optional(list(string))
          x_fd_health_probe = optional(string)
        }))
      })))
      ip_restriction = optional(list(object({
        name                      = optional(string)
        ip_address                = optional(string)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
        action                    = optional(string)
        priority                  = optional(number)
        headers = optional(object({
          x_forwarded_for   = optional(list(string))
          x_forwarded_host  = optional(list(string))
          x_azure_fdid      = optional(list(string))
          x_fd_health_probe = optional(string)
        }))
      })))
    })

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))
    client_certificate_enabled = optional(bool)
    client_certificate_mode    = optional(string)

    auth_settings = optional(object({
      enabled                        = optional(bool)
      token_refresh_extension_hours  = optional(number)
      allowed_external_redirect_urls = optional(list(string))
      unauthenticated_client_action  = optional(string)
      active_directory = optional(object({
        client_id                  = string
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
        allowed_audiences          = optional(list(string))
      }))
      facebook = optional(object({
        app_id                  = string
        app_secret              = optional(string)
        app_secret_setting_name = optional(string)
      }))
      github = optional(object({
        client_id                  = string
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
      }))
      google = optional(object({
        client_id                  = string
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
      }))
      microsoft = optional(object({
        client_id                  = string
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
      }))
      twitter = optional(object({
        consumer_key                 = string
        consumer_secret              = optional(string)
        consumer_secret_setting_name = optional(string)
      }))
      default_provider = optional(string)
    }))

    auth_settings_v2 = optional(object({
      auth_enabled                 = optional(bool)
      require_authentication       = optional(bool)
      unauthenticated_action       = optional(string)
      default_provider             = optional(string)
      forward_proxy_convention     = optional(string)
      cookie_expiration_convention = optional(string)
      cookie_expiration_time       = optional(string)
      nonce_expiration_time        = optional(string)
      active_directory_v2 = optional(object({
        client_id                            = string
        client_secret                        = optional(string)
        client_secret_setting_name           = optional(string)
        tenant_auth_endpoint                 = optional(string)
        client_secret_certificate_thumbprint = optional(string)
        jwt_allowed_groups                   = optional(list(string))
        jwt_allowed_client_applications      = optional(list(string))
      }))
      login = optional(object({
        token_store_enabled            = optional(bool)
        token_refresh_extension_time   = optional(string)
        token_store_path               = optional(string)
        token_store_sas_setting_name   = optional(string)
        preserve_url_fragments         = optional(bool)
        allowed_external_redirect_urls = optional(list(string))
        logout_endpoint                = optional(string)
        cookie_expiration_convention   = optional(string)
        cookie_expiration_time         = optional(string)
        validate_nonce                 = optional(bool)
        nonce_expiration_time          = optional(string)
      }))
      identity_providers = optional(list(object({
        provider                      = string
        client_id                     = string
        client_secret_setting_name    = optional(string)
        openid_configuration_endpoint = optional(string)
        allowed_audiences             = optional(list(string))
        login_scopes                  = optional(list(string))
      })))
    }))

    backup = optional(object({
      name                = string
      storage_account_url = string
      enabled             = optional(bool)
      schedule = object({
        frequency_unit           = string
        frequency_interval       = number
        start_time               = optional(string)
        retention_period_days    = optional(number)
        keep_at_least_one_backup = optional(bool)
      })
    }))
    service_plan_id = optional(string)

    logs = optional(object({
      application_logs = optional(object({
        file_system_level = optional(string)
        azure_blob_storage = optional(object({
          level             = string
          sas_url           = string
          retention_in_days = number
        }))
      }))
      http_logs = optional(object({
        file_system = optional(object({
          retention_in_mb   = optional(number)
          retention_in_days = optional(number)
        }))
        azure_blob_storage = optional(object({
          sas_url           = string
          retention_in_days = optional(number)
        }))
      }))
      detailed_error_messages_enabled = optional(bool)
      failed_request_tracing_enabled  = optional(bool)
    }))

    app_settings = optional(map(string))
    connection_string = optional(list(object({
      name  = string
      type  = string
      value = string
    })))

    storage_account = optional(list(object({
      name         = string
      account_name = string
      access_key   = string
      share_name   = string
      type         = string
      mount_path   = optional(string)
    })))

    tags                                           = optional(map(string))
    client_affinity_enabled                        = optional(bool)
    client_certificate_exclusion_paths             = optional(string)
    ftp_publish_basic_authentication_enabled       = optional(bool)
    public_network_access_enabled                  = optional(bool)
    key_vault_reference_identity_id                = optional(string)
    webdeploy_publish_basic_authentication_enabled = optional(bool)
    https_only                                     = optional(bool)
    enabled                                        = optional(bool)
    virtual_network_subnet_id                      = optional(string)

    slots = optional(list(object({
      name         = string
      app_settings = optional(map(string))
      connection_string = optional(list(object({
        name  = string
        type  = string
        value = string
      })))

      site_config = optional(object({
        always_on                = optional(bool)
        auto_heal_enabled        = optional(bool)
        client_certificate_mode  = optional(string)
        health_check_path        = optional(string)
        websockets_enabled       = optional(bool)
        ftps_state               = optional(string)
        minimum_tls_version      = optional(string)
        remote_debugging_version = optional(string)
        load_balancing_mode      = optional(string)
        application_stack = optional(object({
          docker_image_name           = optional(string)
          docker_registry_url         = optional(string)
          docker_registry_username    = optional(string)
          python_version              = optional(string)
          node_version                = optional(string)
          dotnet_version              = optional(string)
          java_version                = optional(string)
          java_server                 = optional(string)
          java_server_version         = optional(string)
          php_version                 = optional(string)
          ruby_version                = optional(string)
          go_version                  = optional(string)
          use_dotnet_isolated_runtime = optional(bool)
        }))
        ip_restriction = optional(list(object({
          name                      = optional(string)
          ip_address                = optional(string)
          service_tag               = optional(string)
          virtual_network_subnet_id = optional(string)
          action                    = optional(string)
          priority                  = optional(number)
          headers = optional(object({
            x_forwarded_for   = optional(list(string))
            x_forwarded_host  = optional(list(string))
            x_azure_fdid      = optional(list(string))
            x_fd_health_probe = optional(string)
          }))
        })))
      }))
      storage_account = optional(list(object({
        name         = string
        account_name = string
        access_key   = string
        share_name   = string
        type         = string
        mount_path   = optional(string)
      })))

      auth_settings = optional(object({
        enabled = optional(bool)
        active_directory = optional(object({
          client_id                  = string
          client_secret_setting_name = optional(string)
        }))
        default_provider = optional(string)
      }))

      auth_settings_v2 = optional(object({
        enabled = optional(bool)
        login = optional(object({
          token_store_enabled            = optional(bool)
          token_refresh_extension_time   = optional(string)
          token_store_path               = optional(string)
          token_store_sas_setting_name   = optional(string)
          preserve_url_fragments         = optional(bool)
          allowed_external_redirect_urls = optional(list(string))
          logout_endpoint                = optional(string)
          cookie_expiration_convention   = optional(string)
          cookie_expiration_time         = optional(string)
          validate_nonce                 = optional(bool)
          nonce_expiration_time          = optional(string)
        }))
        identity_providers = optional(list(object({
          provider                   = string
          client_id                  = string
          client_secret_setting_name = optional(string)
        })))
      }))

      identity = optional(object({
        type         = string
        identity_ids = optional(list(string))
      }))

      tags                       = optional(map(string))
      client_affinity_enabled    = optional(bool)
      client_certificate_enabled = optional(bool)
      client_certificate_mode    = optional(string)
      https_only                 = optional(bool)
      enabled                    = optional(bool)
      service_plan_id            = optional(string)

      logs = optional(object({
        application_logs = optional(object({
          file_system_level = optional(string)
          azure_blob_storage = optional(object({
            level             = string
            sas_url           = string
            retention_in_days = optional(number)
          }))
        }))
        http_logs = optional(object({
          file_system = optional(object({
            retention_in_mb   = optional(number)
            retention_in_days = optional(number)
          }))
        }))
      }))
      sticky_settings = optional(object({
        app_setting_names       = optional(list(string))
        connection_string_names = optional(list(string))
      }))

      backup = optional(object({
        name                = string
        storage_account_url = string
        enabled             = optional(bool)
        schedule = object({
          frequency_unit           = string
          frequency_interval       = number
          start_time               = optional(string)
          retention_period_days    = optional(number)
          keep_at_least_one_backup = optional(bool)
        })
      }))

    }))),
  })

  # Core Required Fields
  validation {
    condition = (
      var.web_app_config.name != "" &&
      var.web_app_config.resource_group_name != "" &&
      var.web_app_config.location != "" &&
      var.web_app_config.site_config != null &&
      (var.web_app_config.service_plan_id != null && var.web_app_config.service_plan == null) ||
      (var.web_app_config.service_plan_id == null && var.web_app_config.service_plan != null)
    )
    error_message = "The web_app_config object must include non-empty values for name, resource_group_name, location, and site_config, and either service_plan_id or service_plan must be provided, but not both."
  }

  validation {
    condition = (
      var.web_app_config.service_plan_id == "" ||
      can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.Web/serverfarms/.+$", var.web_app_config.service_plan_id))
    )
    error_message = "Invalid service_plan_id. Must be a full resource ID of an App Service Plan."
  }

  validation {
    condition     = length(var.web_app_config.name) >= 2 && length(var.web_app_config.name) <= 64
    error_message = "web_app_config.name must be between 2 and 64 characters long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.web_app_config.name))
    error_message = "web_app_config.name must be alphanumeric and may contain dashes only."
  }

  # Service Plan

  validation {
    condition = (
      var.web_app_config.service_plan != null ||
      var.web_app_config.service_plan_id != null
    )
    error_message = "You must provide either 'service_plan' (to create one) or 'service_plan_id' (to reuse one)."
  }

  validation {
    condition = (
      var.web_app_config.service_plan == null ||
      !contains(["F1", "D1"], var.web_app_config.service_plan.sku_name) ||
      (var.web_app_config.site_config.always_on == null || var.web_app_config.site_config.always_on == false)
    )
    error_message = "F1 and D1 SKUs do not support always_on; it must be false or unset."
  }


  validation {
    condition = (
      var.web_app_config.service_plan == null ||
      var.web_app_config.service_plan.premium_plan_auto_scale_enabled == null ||
      contains([true, false], var.web_app_config.service_plan.premium_plan_auto_scale_enabled)
    )
    error_message = "service_plan.premium_plan_auto_scale_enabled must be true or false."
  }
  validation {
    condition = (
      var.web_app_config.service_plan == null ||
      var.web_app_config.service_plan.maximum_elastic_worker_count == null ||
      contains(["EP1", "EP2", "EP3"], var.web_app_config.service_plan.sku_name) ||
      var.web_app_config.service_plan.premium_plan_auto_scale_enabled == true
    )
    error_message = "service_plan.maximum_elastic_worker_count is only valid with Elastic (EP1, EP2, EP3) or Premium SKUs with premium_plan_auto_scale_enabled set to true."
  }

  validation {
    condition = (
      var.web_app_config.service_plan == null ||
      contains([
        "F1", "D1", "B1", "B2", "B3",
        "S1", "S2", "S3",
        "P0v3", "P1v2", "P2v2", "P3v2",
        "P1v3", "P2v3", "P3v3", "P4mv3", "P5mv3",
        "EP1", "EP2", "EP3",
        "I1v2", "I2v2", "I3v2", "I4v2", "I5v2", "I6v2",
        "WS1", "WS2", "WS3",
        "Y1"
      ], var.web_app_config.service_plan.sku_name)
    )
    error_message = "service_plan.sku_name must be a valid Azure App Service SKU (e.g., 'F1', 'S1', 'P1v3', 'Y1')."
  }

  validation {
    condition = (
      var.web_app_config.service_plan == null ||
      var.web_app_config.service_plan.os_type == "Linux"
    )
    error_message = "This module deploys azurerm_linux_web_app, so service_plan.os_type must be 'Linux'."
  }

  validation {
    condition = (
      var.web_app_config.service_plan == null ||
      var.web_app_config.service_plan.worker_count == null ||
      var.web_app_config.service_plan.worker_count >= 1
    )
    error_message = "service_plan.worker_count must be >= 1 if defined."
  }

  validation {
    condition = (
      var.web_app_config.service_plan == null ||
      var.web_app_config.service_plan.app_service_environment_id == null ||
      contains(["I1v2", "I1mv2", "I2v2", "I2mv2", "I3v2", "I3mv2", "I4v2", "I4mv2", "I5v2", "I5mv2", "I6v2"], var.web_app_config.service_plan.sku_name)
    )
    error_message = "service_plan.app_service_environment_id requires an Isolated SKU (e.g., I1v2, I2v2)."
  }

  validation {
    condition = (
      var.web_app_config.service_plan == null ||
      var.web_app_config.service_plan.zone_balancing_enabled == null ||
      var.web_app_config.service_plan.zone_balancing_enabled == false ||
      (
        contains(["P1v3", "P2v3", "P3v3", "P4mv3", "P5mv3", "EP1", "EP2", "EP3"], var.web_app_config.service_plan.sku_name) &&
        (var.web_app_config.service_plan.worker_count == null || var.web_app_config.service_plan.worker_count % 2 == 0)
      )
    )
    error_message = "If service_plan.zone_balancing_enabled is true, sku_name must be a Premium V3 or Elastic Premium SKU (e.g., P1v3, EP1), and worker_count must be a multiple of the region's availability zones (e.g., 2, 4, 6)."
  }

  validation {
    condition = (
      var.web_app_config.service_plan == null ||
      contains([
        "F1", "D1", "B1", "B2", "B3",
        "S1", "S2", "S3",
        "P1v2", "P2v2", "P3v2",
        "P0v3", "P1v3", "P2v3", "P3v3",
        "P1mv3", "P2mv3", "P3mv3", "P4mv3", "P5mv3",
        "I1v2", "I1mv2", "I2v2", "I2mv2", "I3v2", "I3mv2", "I4v2", "I4mv2", "I5v2", "I5mv2", "I6v2",
        "EP1", "EP2", "EP3",
        "FC1", "Y1",
        "WS1", "WS2", "WS3"
      ], var.web_app_config.service_plan.sku_name)
    )
    error_message = "service_plan.sku_name must be a valid Azure App Service SKU (e.g., 'S1', 'P1v2', 'Y1')."
  }

  # Site Config

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.health_check_path == null ||
      (var.web_app_config.site_config.always_on != null && var.web_app_config.site_config.always_on == true)
    )
    error_message = "site_config.always_on must be true when health_check_path is set, as Azure requires it for health checks."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.application_stack == null ||
      var.web_app_config.site_config.application_stack.dotnet_version == null ||
      (
        can(regex("^[0-9]+\\.[0-9]+$", var.web_app_config.site_config.application_stack.dotnet_version)) &&
        contains(["3.1", "5.0", "6.0", "7.0", "8.0"], var.web_app_config.site_config.application_stack.dotnet_version)
      )
    )
    error_message = "site_config.application_stack.dotnet_version must be in the format 'X.Y' and one of '3.1', '5.0', '6.0', '7.0', or '8.0'."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.application_stack == null ||
      !try(var.web_app_config.site_config.application_stack.use_dotnet_isolated_runtime, false) ||
      contains(["6.0", "7.0", "8.0"], var.web_app_config.site_config.application_stack.dotnet_version)
    )
    error_message = "use_dotnet_isolated_runtime can only be used with .NET versions 6.0, 7.0, or 8.0."
  }

  validation {
    condition = (
      var.web_app_config.site_config.auto_heal_enabled == null ||
      contains([true, false], var.web_app_config.site_config.auto_heal_enabled)
    )
    error_message = "site_config.auto_heal_enabled must be true or false."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.scm_minimum_tls_version == null ||
      contains(["1.0", "1.1", "1.2"], var.web_app_config.site_config.scm_minimum_tls_version)
    )
    error_message = "site_config.scm_minimum_tls_version must be one of '1.0', '1.1', or '1.2'."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.always_on == null ||
      var.web_app_config.service_plan == null ||
      !contains(["F1", "D1", "Y1"], var.web_app_config.service_plan.sku_name) ||
      var.web_app_config.site_config.always_on == false
    )
    error_message = "site_config.always_on must be false when using Free (F1), Shared (D1), or Function (Y1) SKUs."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.load_balancing_mode == null ||
      contains(["WeightedRoundRobin", "LeastRequests", "LeastResponseTime", "WeightedTotalTraffic", "RequestHash", "PerSiteRoundRobin"], var.web_app_config.site_config.load_balancing_mode)
    )
    error_message = "site_config.load_balancing_mode must be one of 'WeightedRoundRobin', 'LeastRequests', 'LeastResponseTime', 'WeightedTotalTraffic', 'RequestHash', or 'PerSiteRoundRobin'."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.ftps_state == null ||
      contains(["AllAllowed", "FtpsOnly", "Disabled"], var.web_app_config.site_config.ftps_state)
    )
    error_message = "site_config.ftps_state must be 'AllAllowed', 'FtpsOnly', or 'Disabled'."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.number_of_workers == null ||
      var.web_app_config.site_config.number_of_workers >= 1
    )
    error_message = "site_config.number_of_workers must be 1 or greater."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.remote_debugging_version == null ||
      contains(["VS2012", "VS2013", "VS2015", "VS2017"], var.web_app_config.site_config.remote_debugging_version)
    )
    error_message = "site_config.remote_debugging_version must be one of 'VS2012', 'VS2013', 'VS2015', or 'VS2017'."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.default_documents == null ||
      alltrue([for doc in var.web_app_config.site_config.default_documents : trim(doc) != ""])
    )
    error_message = "Each site_config.default_documents entry must be a non-empty string."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.api_management_api_id == null ||
      can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.ApiManagement/service/.*/apis/.+$", var.web_app_config.site_config.api_management_api_id))
    )
    error_message = "site_config.api_management_api_id must be a valid API Management API resource ID."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.always_on == null ||
      var.web_app_config.service_plan == null ||
      !contains(["F1", "D1"], var.web_app_config.service_plan.sku_name) ||
      var.web_app_config.site_config.always_on == false
    )
    error_message = "site_config.always_on must be false when using Free (F1) or Shared (D1) SKUs."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.minimum_tls_version == null ||
      contains(["1.0", "1.1", "1.2"], var.web_app_config.site_config.minimum_tls_version)
    )
    error_message = "site_config.minimum_tls_version must be one of '1.0', '1.1', or '1.2'."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.linux_fx_version == null ||
      can(regex("^(DOCKER|JAVA|NODE|PYTHON)\\|.*$", var.web_app_config.site_config.linux_fx_version))
    )
    error_message = "site_config.linux_fx_version must begin with 'DOCKER|', 'JAVA|', 'NODE|', or 'PYTHON|' when using custom containers or stacks."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.health_check_path == null ||
      startswith(var.web_app_config.site_config.health_check_path, "/")
    )
    error_message = "site_config.health_check_path must start with '/'."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.api_definition_url == null ||
      can(regex("^https://", var.web_app_config.site_config.api_definition_url))
    )
    error_message = "site_config.api_definition_url must start with 'https://'."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.health_check_eviction_time_in_min == null ||
      var.web_app_config.site_config.health_check_path == null ||
      (var.web_app_config.site_config.health_check_eviction_time_in_min >= 2 && var.web_app_config.site_config.health_check_eviction_time_in_min <= 10)
    )
    error_message = "site_config.health_check_eviction_time_in_min must be between 2 and 10 minutes if health_check_path is set."
  }

  # Validate vnet_route_all_enabled requires virtual_network_subnet_id
  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.vnet_route_all_enabled == null ||
      var.web_app_config.site_config.vnet_route_all_enabled == false ||
      var.web_app_config.virtual_network_subnet_id != null
    )
    error_message = "vnet_route_all_enabled requires virtual_network_subnet_id to be set."
  }

  # Validate http2_enabled as a boolean
  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.http2_enabled == null ||
      contains([true, false], var.web_app_config.site_config.http2_enabled)
    )
    error_message = "http2_enabled must be true or false."
  }

  # Validate managed_pipeline_mode
  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.managed_pipeline_mode == null ||
      contains(["Integrated", "Classic"], var.web_app_config.site_config.managed_pipeline_mode)
    )
    error_message = "managed_pipeline_mode must be 'Integrated' or 'Classic'."
  }

  # Validate container_registry_managed_identity_client_id requires use_managed_identity
  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.container_registry_managed_identity_client_id == null ||
      (var.web_app_config.site_config.container_registry_use_managed_identity != null && var.web_app_config.site_config.container_registry_use_managed_identity == true)
    )
    error_message = "container_registry_managed_identity_client_id requires container_registry_use_managed_identity to be true."
  }

  # Validate worker_count upper limit
  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.number_of_workers == null ||
      (var.web_app_config.site_config.number_of_workers >= 1 && var.web_app_config.site_config.number_of_workers <= 20)
    )
    error_message = "number_of_workers must be between 1 and 20, depending on SKU."
  }

  # Application Stack


  validation {
    condition     = var.web_app_config.site_config == null || var.web_app_config.site_config.application_stack == null || var.web_app_config.site_config.application_stack.java_server == null || contains(["JAVA", "TOMCAT", "JBOSSEAP"], var.web_app_config.site_config.application_stack.java_server)
    error_message = "application_stack.java_server must be 'JAVA', 'TOMCAT', or 'JBOSSEAP'."
  }

  validation {
    condition     = var.web_app_config.site_config == null || var.web_app_config.site_config.application_stack == null || var.web_app_config.site_config.application_stack.node_version == null || contains(["12-lts", "14-lts", "16-lts", "18-lts", "20-lts", "22-lts"], var.web_app_config.site_config.application_stack.node_version)
    error_message = "application_stack.node_version must be one of '12-lts', '14-lts', '16-lts', '18-lts', '20-lts', or '22-lts'."
  }



  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.application_stack == null ||
      var.web_app_config.site_config.application_stack.ruby_version == null ||
      contains(["2.7"], var.web_app_config.site_config.application_stack.ruby_version)
    )
    error_message = "site_config.application_stack.ruby_version must be '2.7' (2.5 and 2.6 are no longer supported)."
  }

  validation {
    condition     = var.web_app_config.site_config == null || var.web_app_config.site_config.application_stack == null || !(var.web_app_config.site_config.application_stack.node_version != null && var.web_app_config.site_config.application_stack.java_version != null)
    error_message = "application_stack.node_version and java_version cannot both be set at the same time."
  }



  validation {
    condition     = var.web_app_config.site_config == null || var.web_app_config.site_config.application_stack == null || var.web_app_config.site_config.application_stack.python_version == null || contains(["3.7", "3.8", "3.9", "3.10", "3.11"], var.web_app_config.site_config.application_stack.python_version)
    error_message = "site_config.application_stack.python_version must be one of '3.7', '3.8', '3.9', '3.10', or '3.11'."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.application_stack == null ||
      var.web_app_config.site_config.application_stack.php_version == null ||
      contains(["7.4", "8.0", "8.1", "8.2", "8.3"], var.web_app_config.site_config.application_stack.php_version)
    )
    error_message = "site_config.application_stack.php_version must be one of '7.4', '8.0', '8.1', '8.2', or '8.3'. Note: PHP 5.6 is deprecated and no longer supported."
  }
  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.app_command_line == null ||
      var.web_app_config.site_config.linux_fx_version != null
    )
    error_message = "site_config.app_command_line requires linux_fx_version to be set (used for custom container or stack)."
  }



  validation {
    condition     = var.web_app_config.site_config == null || var.web_app_config.site_config.application_stack == null || var.web_app_config.site_config.application_stack.java_version == null || contains(["8", "11", "17", "21"], var.web_app_config.site_config.application_stack.java_version)
    error_message = "application_stack.java_version must be one of '8', '11', '17', or '21'."
  }

  validation {
    condition     = var.web_app_config.site_config == null || var.web_app_config.site_config.application_stack == null || var.web_app_config.site_config.application_stack.go_version == null || contains(["1.18", "1.19"], var.web_app_config.site_config.application_stack.go_version)
    error_message = "application_stack.go_version must be one of '1.18' or '1.19'."
  }

  validation {
    condition     = var.web_app_config.site_config == null || var.web_app_config.site_config.application_stack == null || var.web_app_config.site_config.application_stack.docker_image_name == null || (var.web_app_config.site_config.application_stack.docker_registry_url != null)
    error_message = "If docker_image_name is specified, docker_registry_url must also be provided."
  }

  # IP Restrictions

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.ip_restriction == null ||
      length(var.web_app_config.site_config.ip_restriction) <= 512
    )
    error_message = "site_config.ip_restriction must not exceed 512 rules, per Azure's limit."
  }

  validation {
    condition = (
      var.web_app_config.site_config.scm_ip_restriction == null ||
      alltrue([for r in var.web_app_config.site_config.scm_ip_restriction : r.headers == null || r.headers.x_forwarded_for == null || alltrue([for ip in r.headers.x_forwarded_for : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(/[0-9]{1,2})?$", ip))])])
    )
    error_message = "scm_ip_restriction.headers.x_forwarded_for must contain valid IP addresses or CIDR notations (e.g., '192.168.1.1', '10.0.0.0/24')."
  }

  validation {
    condition = (
      var.web_app_config.site_config.scm_ip_restriction == null ||
      alltrue([for r in var.web_app_config.site_config.scm_ip_restriction : r.headers == null || r.headers.x_forwarded_host == null || alltrue([for host in r.headers.x_forwarded_host : can(regex("^[a-zA-Z0-9.-]+$", host))])])
    )
    error_message = "scm_ip_restriction.headers.x_forwarded_host must contain valid hostnames (e.g., 'example.com')."
  }

  validation {
    condition = (
      var.web_app_config.site_config.scm_ip_restriction == null ||
      alltrue([for r in var.web_app_config.site_config.scm_ip_restriction : r.headers == null || r.headers.x_azure_fdid == null || alltrue([for fdid in r.headers.x_azure_fdid : can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", fdid))])])
    )
    error_message = "scm_ip_restriction.headers.x_azure_fdid must contain valid GUIDs (e.g., '123e4567-e89b-12d3-a456-426614174000')."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.ip_restriction == null ||
      alltrue([for rule in var.web_app_config.site_config.ip_restriction : (
        rule.headers == null ||
        (
          (rule.headers.x_forwarded_for != null && length(rule.headers.x_forwarded_for) > 0) ||
          (rule.headers.x_azure_fdid != null && length(rule.headers.x_azure_fdid) > 0) ||
          (rule.headers.x_forwarded_host != null && length(rule.headers.x_forwarded_host) > 0)
        )
      )])
    )
    error_message = "Each site_config.ip_restriction.headers block must specify at least one non-empty list (x_forwarded_for, x_azure_fdid, or x_forwarded_host)."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.ip_restriction == null ||
      length(var.web_app_config.site_config.ip_restriction) == 0 ||
      alltrue([for rule in var.web_app_config.site_config.ip_restriction : ((rule.ip_address != null ? 1 : 0) + (rule.service_tag != null ? 1 : 0) + (rule.virtual_network_subnet_id != null ? 1 : 0)) == 1])
    )
    error_message = "Each site_config.ip_restriction must specify exactly one of ip_address, service_tag, or virtual_network_subnet_id."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.ip_restriction == null ||
      length(distinct([for rule in var.web_app_config.site_config.ip_restriction : rule.priority])) == length([for rule in var.web_app_config.site_config.ip_restriction : rule.priority])
    )
    error_message = "Each site_config.ip_restriction.priority value must be unique."
  }

  validation {
    condition     = can(index(["Allow", "Deny"], var.web_app_config.site_config.scm_ip_restriction_default_action)) || var.web_app_config.site_config.scm_ip_restriction_default_action == null
    error_message = "scm_ip_restriction_default_action must be either 'Allow' or 'Deny'."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.scm_ip_restriction == null ||
      alltrue([for rule in var.web_app_config.site_config.scm_ip_restriction : rule.action == null || contains(["Allow", "Deny"], rule.action)])
    )
    error_message = "Each scm_ip_restriction.action must be 'Allow' or 'Deny' if specified."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.ip_restriction == null ||
      alltrue([for rule in var.web_app_config.site_config.ip_restriction : rule.action == null || contains(["Allow", "Deny"], rule.action)])
    )
    error_message = "Each site_config.ip_restriction.action must be either 'Allow' or 'Deny' if specified."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.ip_restriction == null ||
      alltrue([for rule in var.web_app_config.site_config.ip_restriction : rule.priority == null || (rule.priority >= 100 && rule.priority <= 65535)])
    )
    error_message = "Each site_config.ip_restriction.priority must be between 100 and 65535."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.scm_ip_restriction == null ||
      alltrue([for rule in var.web_app_config.site_config.scm_ip_restriction : ((rule.ip_address != null ? 1 : 0) + (rule.service_tag != null ? 1 : 0) + (rule.virtual_network_subnet_id != null ? 1 : 0)) == 1])
    )
    error_message = "Each scm_ip_restriction must specify exactly one of ip_address, service_tag, or virtual_network_subnet_id."
  }

  # Auto Heal Settings
  validation {
    condition     = var.web_app_config.site_config == null || var.web_app_config.site_config.auto_heal_setting == null || var.web_app_config.site_config.auto_heal_setting.actions == null || contains(["Recycle", "LogEvent", "CustomAction"], var.web_app_config.site_config.auto_heal_setting.actions.action_type)
    error_message = "auto_heal_setting.actions.action_type must be one of 'Recycle', 'LogEvent', or 'CustomAction'."
  }

  validation {
    condition = var.web_app_config.site_config == null || var.web_app_config.site_config.auto_heal_setting == null || var.web_app_config.site_config.auto_heal_setting.triggers == null || (
      (var.web_app_config.site_config.auto_heal_setting.triggers.slow_request != null) ||
      (var.web_app_config.site_config.auto_heal_setting.triggers.status_code != null) ||
      (var.web_app_config.site_config.auto_heal_setting.triggers.requests != null)
    )
    error_message = "At least one auto_heal trigger (slow_request, status_code, or requests) must be defined if triggers are set."
  }

  validation {
    condition     = var.web_app_config.site_config == null || var.web_app_config.site_config.auto_heal_setting == null || var.web_app_config.site_config.auto_heal_setting.triggers == null || var.web_app_config.site_config.auto_heal_setting.triggers.status_code == null || alltrue([for sc in var.web_app_config.site_config.auto_heal_setting.triggers.status_code : can(regex("^[0-9]{3}-[0-9]{3}$", sc.status_code_range))])
    error_message = "Each auto_heal_setting.triggers.status_code.status_code_range must be in the format 'xxx-yyy' (e.g., '500-599')."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.auto_heal_enabled != true ||
      var.web_app_config.site_config.auto_heal_setting != null
    )
    error_message = "auto_heal_setting must be provided if auto_heal_enabled is true."
  }

  # CORS Settings

  validation {
    condition = (
      var.web_app_config.site_config.application_stack == null ||
      var.web_app_config.site_config.application_stack.docker_registry_username == null ||
      trim(var.web_app_config.site_config.application_stack.docker_registry_username, " ") != ""
    )
    error_message = "site_config.application_stack.docker_registry_username must be a non-empty string if provided."
  }
  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.cors == null ||
      length(var.web_app_config.site_config.cors.allowed_origins) > 0
    )
    error_message = "site_config.cors.allowed_origins must contain at least one origin if cors is defined."
  }

  validation {
    condition = (
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.cors == null ||
      alltrue([for origin in var.web_app_config.site_config.cors.allowed_origins : can(regex("^(https?://)?[a-zA-Z0-9.-]+(:[0-9]+)?$", origin))])
    )
    error_message = "Each site_config.cors.allowed_origin must be a valid URL or hostname (e.g., https://example.com)."
  }

  # App Settings

  validation {
    condition = (
      var.web_app_config.app_settings == null ||
      sum([for k, v in var.web_app_config.app_settings : length(k) + length(v)]) <= 102400
    )
    error_message = "The total size of app_settings (keys + values) must not exceed 100KB (102,400 characters)."
  }

  validation {
    condition = (
      var.web_app_config.app_settings == null ||
      alltrue([for v in values(var.web_app_config.app_settings) : trim(v, " ") != ""])
    )
    error_message = "app_settings values must not be empty strings."
  }

  validation {
    condition = (
      var.web_app_config.app_settings == null ||
      alltrue([for k in keys(var.web_app_config.app_settings) : length(k) <= 255])
    )
    error_message = "app_settings keys must not exceed 255 characters."
  }

  validation {
    condition = (
      var.web_app_config.app_settings == null ||
      alltrue([for v in values(var.web_app_config.app_settings) : length(v) <= 4096])
    )
    error_message = "app_settings values must not exceed 4096 characters."
  }
  validation {
    condition     = var.web_app_config.app_settings == null || length([for k in keys(var.web_app_config.app_settings) : k if trim(k, " ") == ""]) == 0
    error_message = "App setting keys must not be empty."
  }

  # Validate https_only as a boolean
  validation {
    condition = (
      var.web_app_config.https_only == null ||
      contains([true, false], var.web_app_config.https_only)
    )
    error_message = "https_only must be true or false."
  }

  # Warn if https_only is false
  validation {
    condition = (
      var.web_app_config.https_only == null ||
      var.web_app_config.https_only == true
    )
    error_message = "Setting https_only to false is not recommended for security; HTTPS should be enforced."
  }

  # Validate client_affinity_enabled as a boolean
  validation {
    condition = (
      var.web_app_config.client_affinity_enabled == null ||
      contains([true, false], var.web_app_config.client_affinity_enabled)
    )
    error_message = "client_affinity_enabled must be true or false."
  }

  # Validate enabled as a boolean
  validation {
    condition = (
      var.web_app_config.enabled == null ||
      contains([true, false], var.web_app_config.enabled)
    )
    error_message = "enabled must be true or false."
  }

  # Validate ftp_publish_basic_authentication_enabled as a boolean
  validation {
    condition = (
      var.web_app_config.ftp_publish_basic_authentication_enabled == null ||
      contains([true, false], var.web_app_config.ftp_publish_basic_authentication_enabled)
    )
    error_message = "ftp_publish_basic_authentication_enabled must be true or false."
  }

  # Warn if FTP is enabled
  validation {
    condition = (
      var.web_app_config.ftp_publish_basic_authentication_enabled == null ||
      var.web_app_config.ftp_publish_basic_authentication_enabled == false
    )
    error_message = "Enabling FTP (ftp_publish_basic_authentication_enabled=true) is not recommended; use SCM or other secure methods instead."
  }

  # Validate client_certificate_exclusion_paths length
  validation {
    condition = (
      var.web_app_config.client_certificate_exclusion_paths == null ||
      length(split(",", var.web_app_config.client_certificate_exclusion_paths)) <= 50
    )
    error_message = "client_certificate_exclusion_paths must not exceed 50 comma-separated paths."
  }

  # Connection Strings

  validation {
    condition = (
      var.web_app_config.connection_string == null ||
      alltrue([for cs in var.web_app_config.connection_string : length(cs.name) <= 255])
    )
    error_message = "connection_string.name must not exceed 255 characters."
  }

  validation {
    condition = (
      var.web_app_config.connection_string == null ||
      alltrue([for cs in var.web_app_config.connection_string : length(cs.value) <= 4096])
    )
    error_message = "connection_string.value must not exceed 4096 characters."
  }
  validation {
    condition     = var.web_app_config.connection_string == null || length(distinct([for cs in var.web_app_config.connection_string : cs.name])) == length(var.web_app_config.connection_string)
    error_message = "Connection string names must be unique."
  }

  validation {
    condition     = var.web_app_config.slots == null || length(flatten([for s in var.web_app_config.slots : s.connection_string == null ? [true] : [for cs in s.connection_string : contains(["APIHub", "Custom", "DocDb", "EventHub", "MySQL", "NotificationHub", "PostgreSQL", "RedisCache", "ServiceBus", "SQLAzure", "SQLServer", "AzureCosmosDB", "MongoDB"], cs.type)]])) > 0
    error_message = "Each slot.connection_string.type must be one of 'APIHub', 'Custom', 'DocDb', 'EventHub', 'MySQL', 'NotificationHub', 'PostgreSQL', 'RedisCache', 'ServiceBus', 'SQLAzure', 'SQLServer', 'AzureCosmosDB', or 'MongoDB'."
  }

  validation {
    condition     = var.web_app_config.connection_string == null || length([for cs in var.web_app_config.connection_string : cs if trim(cs.name, " ") == ""]) == 0
    error_message = "connection_string.name cannot be empty."
  }

  validation {
    condition     = var.web_app_config.connection_string == null || length([for cs in var.web_app_config.connection_string : cs if trim(cs.value, " ") == ""]) == 0
    error_message = "connection_string.value cannot be empty."
  }

  validation {
    condition = (
      var.web_app_config.connection_string == null ||
      var.web_app_config.slots == null ||
      length(distinct(flatten([
        [for cs in var.web_app_config.connection_string : cs.name],
        flatten([for slot in var.web_app_config.slots : slot.connection_string == null ? [] : [for cs in slot.connection_string : cs.name]])
      ]))) ==
      (
        length(var.web_app_config.connection_string) +
        sum([for slot in var.web_app_config.slots : slot.connection_string == null ? 0 : length(slot.connection_string)])
      )
    )
    error_message = "Connection string names must be unique across main web app and all slots."
  }

  # Sticky Settings

  validation {
    condition = (
      var.web_app_config.sticky_settings == null ||
      var.web_app_config.sticky_settings.app_setting_names == null ||
      var.web_app_config.app_settings == null ||
      alltrue([for name in var.web_app_config.sticky_settings.app_setting_names : contains(keys(var.web_app_config.app_settings), name)])
    )
    error_message = "sticky_settings.app_setting_names must reference existing app_settings keys."
  }

  validation {
    condition = (
      var.web_app_config.sticky_settings == null ||
      var.web_app_config.sticky_settings.connection_string_names == null ||
      var.web_app_config.connection_string == null ||
      alltrue([for name in var.web_app_config.sticky_settings.connection_string_names : contains([for cs in var.web_app_config.connection_string : cs.name], name)])
    )
    error_message = "sticky_settings.connection_string_names must reference existing connection_string names."
  }
  validation {
    condition = (
      var.web_app_config.sticky_settings == null ||
      (
        var.web_app_config.sticky_settings.app_setting_names != null ||
        var.web_app_config.sticky_settings.connection_string_names != null
      )
    )
    error_message = "If sticky_settings is defined, at least one of app_setting_names or connection_string_names must be provided."
  }

  validation {
    condition = (
      var.web_app_config.sticky_settings == null ||
      length(distinct(
        concat(
          try(var.web_app_config.sticky_settings.app_setting_names, []),
          try(var.web_app_config.sticky_settings.connection_string_names, [])
        )
        )) == (
        length(try(var.web_app_config.sticky_settings.app_setting_names, [])) +
        length(try(var.web_app_config.sticky_settings.connection_string_names, []))
      )
    )
    error_message = "sticky_settings must not contain overlapping names between app_setting_names and connection_string_names."
  }

  validation {
    condition = (
      var.web_app_config.sticky_settings == null ||
      var.web_app_config.sticky_settings.app_setting_names == null ||
      alltrue([for name in var.web_app_config.sticky_settings.app_setting_names : trim(name) != ""])
    )
    error_message = "sticky_settings.app_setting_names must not contain empty strings."
  }

  validation {
    condition = (
      var.web_app_config.sticky_settings == null ||
      var.web_app_config.sticky_settings.connection_string_names == null ||
      alltrue([for name in var.web_app_config.sticky_settings.connection_string_names : trim(name) != ""])
    )
    error_message = "sticky_settings.connection_string_names must not contain empty strings."
  }

  validation {
    condition     = var.web_app_config.sticky_settings == null || (length(var.web_app_config.sticky_settings.app_setting_names) > 0 || length(var.web_app_config.sticky_settings.connection_string_names) > 0)
    error_message = "At least one sticky setting (app_setting_names or connection_string_names) must be provided if sticky_settings is enabled."
  }

  validation {
    condition = (
      var.web_app_config.slots == null ||
      alltrue([for s in var.web_app_config.slots : s.sticky_settings == null || (
        (s.sticky_settings.app_setting_names != null && length(s.sticky_settings.app_setting_names) > 0) ||
        (s.sticky_settings.connection_string_names != null && length(s.sticky_settings.connection_string_names) > 0)
      )])
    )
    error_message = "Each slot's sticky_settings must include at least one of app_setting_names or connection_string_names."
  }

  # Storage Accounts

  validation {
    condition = (
      var.web_app_config.storage_account == null ||
      length(var.web_app_config.storage_account) <= 5
    )
    error_message = "The number of storage_account entries must not exceed 5, per Azure's limit."
  }

  validation {
    condition = (
      var.web_app_config.storage_account == null ||
      alltrue([for sa in var.web_app_config.storage_account : length(sa.account_name) >= 3 && length(sa.account_name) <= 24])
    )
    error_message = "storage_account.account_name must be between 3 and 24 characters."
  }

  validation {
    condition = (
      var.web_app_config.storage_account == null ||
      alltrue([for sa in var.web_app_config.storage_account : length(sa.share_name) <= 63])
    )
    error_message = "storage_account.share_name must not exceed 63 characters."
  }

  validation {
    condition = (
      var.web_app_config.storage_account == null ||
      length(distinct([for sa in var.web_app_config.storage_account : sa.mount_path if sa.mount_path != null])) == length([for sa in var.web_app_config.storage_account : sa.mount_path if sa.mount_path != null])
    )
    error_message = "storage_account.mount_path values must be unique if specified."
  }
  validation {
    condition     = var.web_app_config.storage_account == null || alltrue([for sa in var.web_app_config.storage_account : contains(["AzureFiles", "AzureBlob"], sa.type)])
    error_message = "storage_account.type must be either 'AzureFiles' or 'AzureBlob'."
  }

  validation {
    condition = (
      var.web_app_config.storage_account == null ||
      alltrue([for sa in var.web_app_config.storage_account : trim(sa.name) != "" && trim(sa.account_name) != "" && trim(sa.access_key) != "" && trim(sa.share_name) != "" && contains(["AzureFiles", "AzureBlob"], sa.type)])
    )
    error_message = "Each storage_account must include name, account_name, access_key, share_name, and type ('AzureFiles' or 'AzureBlob')."
  }

  validation {
    condition = (
      var.web_app_config.storage_account == null ||
      alltrue([for sa in var.web_app_config.storage_account : sa.mount_path == null || startswith(sa.mount_path, "/")])
    )
    error_message = "Each storage_account.mount_path must start with '/' if defined."
  }

  validation {
    condition = (
      var.web_app_config.storage_account == null ||
      alltrue([for sa in var.web_app_config.storage_account : can(regex("^[a-z0-9](?!.*--)[a-z0-9-]{1,61}[a-z0-9]$", sa.name))])
    )
    error_message = "storage_account.name must follow Azure naming rules: lowercase, alphanumeric or dashes, 3–63 characters."
  }

  validation {
    condition = (
      var.web_app_config.storage_account == null ||
      alltrue([for sa in var.web_app_config.storage_account : sa.access_key == null || length(sa.access_key) > 30])
    )
    error_message = "Each storage_account.access_key must appear to be a valid key (at least 30 characters)."
  }

  # 32 Bit Worker
  validation {
    condition = (
      var.web_app_config.site_config.use_32_bit_worker == null ||
      contains([true, false], var.web_app_config.site_config.use_32_bit_worker)
    )
    error_message = "site_config.use_32_bit_worker must be true or false."
  }

  validation {
    condition = (
      var.web_app_config.site_config.use_32_bit_worker == null ||
      var.web_app_config.service_plan == null ||
      var.web_app_config.site_config.use_32_bit_worker == false ||
      !contains(["P1v3", "P2v3", "P3v3"], var.web_app_config.service_plan.sku_name)
    )
    error_message = "site_config.use_32_bit_worker=true is not supported with PremiumV3 SKUs (P1v3, P2v3, P3v3)."
  }

  # Logs

  validation {
    condition = (
      var.web_app_config.logs == null ||
      var.web_app_config.logs.application_logs == null ||
      var.web_app_config.logs.application_logs.azure_blob_storage == null ||
      contains(["Verbose", "Information", "Warning", "Error"], var.web_app_config.logs.application_logs.azure_blob_storage.level)
    )
    error_message = "logs.application_logs.azure_blob_storage.level must be one of 'Verbose', 'Information', 'Warning', or 'Error'."
  }
  validation {
    condition     = var.web_app_config.logs == null || var.web_app_config.logs.application_logs == null || var.web_app_config.logs.application_logs.file_system_level == null || contains(["Verbose", "Information", "Warning", "Error"], var.web_app_config.logs.application_logs.file_system_level)
    error_message = "logs.application_logs.file_system_level must be one of 'Verbose', 'Information', 'Warning', or 'Error'."
  }

  validation {
    condition     = var.web_app_config.logs == null || var.web_app_config.logs.application_logs == null || var.web_app_config.logs.application_logs.azure_blob_storage == null || (var.web_app_config.logs.application_logs.azure_blob_storage.retention_in_days != null && var.web_app_config.logs.application_logs.azure_blob_storage.sas_url != "")
    error_message = "If logs.application_logs.azure_blob_storage is configured, both retention_in_days and sas_url must be provided."
  }

  validation {
    condition     = var.web_app_config.logs == null || var.web_app_config.logs.application_logs == null || var.web_app_config.logs.application_logs.azure_blob_storage == null || var.web_app_config.logs.application_logs.azure_blob_storage.retention_in_days >= 0
    error_message = "logs.application_logs.azure_blob_storage.retention_in_days cannot be negative."
  }

  validation {
    condition     = var.web_app_config.logs == null || var.web_app_config.logs.http_logs == null || var.web_app_config.logs.http_logs.azure_blob_storage == null || (var.web_app_config.logs.http_logs.azure_blob_storage.retention_in_days != null && var.web_app_config.logs.http_logs.azure_blob_storage.sas_url != "")
    error_message = "If logs.http_logs.azure_blob_storage is configured, both retention_in_days and sas_url must be provided."
  }

  validation {
    condition     = var.web_app_config.logs == null || var.web_app_config.logs.http_logs == null || var.web_app_config.logs.http_logs.azure_blob_storage == null || var.web_app_config.logs.http_logs.azure_blob_storage.retention_in_days >= 0
    error_message = "logs.http_logs.azure_blob_storage.retention_in_days cannot be negative."
  }

  validation {
    condition     = var.web_app_config.logs == null || var.web_app_config.logs.http_logs == null || var.web_app_config.logs.http_logs.file_system == null || (var.web_app_config.logs.http_logs.file_system.retention_in_days != null && var.web_app_config.logs.http_logs.file_system.retention_in_mb != null)
    error_message = "If logs.http_logs.file_system is configured, both retention_in_days and retention_in_mb must be set."
  }

  validation {
    condition     = var.web_app_config.logs == null || var.web_app_config.logs.http_logs == null || var.web_app_config.logs.http_logs.file_system == null || (var.web_app_config.logs.http_logs.file_system.retention_in_days >= 0 && var.web_app_config.logs.http_logs.file_system.retention_in_mb > 0)
    error_message = "logs.http_logs.file_system.retention_in_days must be >= 0 and retention_in_mb must be > 0."
  }

  validation {
    condition     = var.web_app_config.logs == null || var.web_app_config.logs.application_logs == null || var.web_app_config.logs.application_logs.azure_blob_storage == null || var.web_app_config.logs.application_logs.azure_blob_storage.level != ""
    error_message = "logs.application_logs.azure_blob_storage.level must not be empty if blob storage logging is configured."
  }

  validation {
    condition     = var.web_app_config.logs == null || var.web_app_config.logs.http_logs == null || var.web_app_config.logs.http_logs.azure_blob_storage == null || can(regex("^https://.*$", var.web_app_config.logs.http_logs.azure_blob_storage.sas_url))
    error_message = "logs.http_logs.azure_blob_storage.sas_url must start with 'https://'."
  }

  # Backup

  validation {
    condition = (
      var.web_app_config.backup == null ||
      (
        (var.web_app_config.backup.schedule.frequency_unit == "Hour" && var.web_app_config.backup.schedule.frequency_interval >= 1 && var.web_app_config.backup.schedule.frequency_interval <= 720) ||
        (var.web_app_config.backup.schedule.frequency_unit == "Day" && var.web_app_config.backup.schedule.frequency_interval >= 1 && var.web_app_config.backup.schedule.frequency_interval <= 30)
      )
    )
    error_message = "backup.schedule.frequency_interval must be 1-720 hours (30 days) for 'Hour' or 1-30 days for 'Day'."
  }

  validation {
    condition = (
      var.web_app_config.backup == null ||
      var.web_app_config.backup.schedule == null ||
      var.web_app_config.backup.schedule.start_time == null ||
      timestamp() < var.web_app_config.backup.schedule.start_time
    )
    error_message = "backup.schedule.start_time must be a future date relative to March 31, 2025."
  }

  validation {
    condition = (
      var.web_app_config.backup == null ||
      var.web_app_config.service_plan == null ||
      contains(["S1", "S2", "S3", "P1v2", "P2v2", "P3v2", "P0v3", "P1v3", "P2v3", "P3v3", "P4mv3", "P5mv3", "I1v2", "I2v2", "I3v2", "I4v2", "I5v2", "I6v2"], var.web_app_config.service_plan.sku_name)
    )
    error_message = "backup is only supported on Standard (S1, S2, S3), Premium (P0v3, P1v2, P2v2, P3v2, P1v3, P2v3, P3v3, P4mv3, P5mv3), or Isolated (I1v2, I2v2, I3v2, I4v2, I5v2, I6v2) SKUs."
  }
  validation {
    condition     = var.web_app_config.backup == null || var.web_app_config.backup.schedule == null || contains(["Day", "Hour"], var.web_app_config.backup.schedule.frequency_unit)
    error_message = "backup.schedule.frequency_unit must be 'Day' or 'Hour'."
  }

  validation {
    condition     = var.web_app_config.backup == null || var.web_app_config.backup.schedule == null || var.web_app_config.backup.schedule.frequency_interval == null || var.web_app_config.backup.schedule.frequency_interval > 0
    error_message = "backup.schedule.frequency_interval must be a positive number."
  }

  validation {
    condition     = var.web_app_config.backup == null || var.web_app_config.backup.schedule == null || var.web_app_config.backup.schedule.retention_period_days == null || var.web_app_config.backup.schedule.retention_period_days >= 0
    error_message = "backup.schedule.retention_period_days cannot be negative."
  }

  validation {
    condition     = var.web_app_config.backup == null || var.web_app_config.backup.schedule == null || var.web_app_config.backup.schedule.start_time == null || can(regex("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$", var.web_app_config.backup.schedule.start_time))
    error_message = "backup.schedule.start_time must be in RFC3339 date-time format (e.g. 2025-01-01T00:00:00Z)."
  }

  validation {
    condition     = var.web_app_config.backup == null || (var.web_app_config.backup.name != "" && var.web_app_config.backup.schedule != null && var.web_app_config.backup.storage_account_url != "")
    error_message = "backup.name, backup.schedule, and backup.storage_account_url are required when backup is configured."
  }

  # Auth Settings (V1)

  validation {
    condition = (
      var.web_app_config.auth_settings == null ||
      var.web_app_config.auth_settings.active_directory == null ||
      var.web_app_config.auth_settings.active_directory.allowed_audiences == null ||
      alltrue([for aud in var.web_app_config.auth_settings.active_directory.allowed_audiences : can(regex("^https?://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?$", aud))])
    )
    error_message = "auth_settings.active_directory.allowed_audiences must contain valid URLs (e.g., 'https://example.com')."
  }
  validation {
    condition = var.web_app_config.auth_settings == null || var.web_app_config.auth_settings.default_provider == null || contains([
      "BuiltInAuthenticationProviderAzureActiveDirectory",
      "BuiltInAuthenticationProviderFacebook",
      "BuiltInAuthenticationProviderGoogle",
      "BuiltInAuthenticationProviderMicrosoftAccount",
      "BuiltInAuthenticationProviderTwitter",
      "BuiltInAuthenticationProviderGithub"
    ], var.web_app_config.auth_settings.default_provider)
    error_message = "auth_settings.default_provider must be one of the documented provider constants (AzureActiveDirectory, Facebook, Google, MicrosoftAccount, Twitter, Github)."
  }

  validation {
    condition     = var.web_app_config.auth_settings == null || var.web_app_config.auth_settings.unauthenticated_client_action == null || contains(["RedirectToLoginPage", "AllowAnonymous"], var.web_app_config.auth_settings.unauthenticated_client_action)
    error_message = "auth_settings.unauthenticated_client_action must be either 'RedirectToLoginPage' or 'AllowAnonymous'."
  }

  validation {
    condition     = var.web_app_config.auth_settings == null || var.web_app_config.auth_settings.unauthenticated_client_action != "RedirectToLoginPage" || (((var.web_app_config.auth_settings.active_directory != null ? 1 : 0) + (var.web_app_config.auth_settings.facebook != null ? 1 : 0) + (var.web_app_config.auth_settings.github != null ? 1 : 0) + (var.web_app_config.auth_settings.google != null ? 1 : 0) + (var.web_app_config.auth_settings.microsoft != null ? 1 : 0) + (var.web_app_config.auth_settings.twitter != null ? 1 : 0)) <= 1 || var.web_app_config.auth_settings.default_provider != null)
    error_message = "If multiple identity providers are configured and unauthenticated_client_action = 'RedirectToLoginPage', a default_provider must be specified."
  }

  validation {
    condition     = var.web_app_config.auth_settings == null || var.web_app_config.auth_settings.active_directory == null || (var.web_app_config.auth_settings.active_directory.client_id != null && var.web_app_config.auth_settings.active_directory.client_id != "")
    error_message = "auth_settings.active_directory.client_id is required when using Azure Active Directory login."
  }

  validation {
    condition     = var.web_app_config.auth_settings == null || var.web_app_config.auth_settings.facebook == null || (var.web_app_config.auth_settings.facebook.app_id != null && var.web_app_config.auth_settings.facebook.app_id != "")
    error_message = "auth_settings.facebook.app_id is required when using Facebook login."
  }

  validation {
    condition     = var.web_app_config.auth_settings == null || var.web_app_config.auth_settings.github == null || (var.web_app_config.auth_settings.github.client_id != null && var.web_app_config.auth_settings.github.client_id != "")
    error_message = "auth_settings.github.client_id is required when using GitHub login."
  }

  validation {
    condition     = var.web_app_config.auth_settings == null || var.web_app_config.auth_settings.google == null || (var.web_app_config.auth_settings.google.client_id != null && var.web_app_config.auth_settings.google.client_id != "")
    error_message = "auth_settings.google.client_id is required when using Google login."
  }

  validation {
    condition     = var.web_app_config.auth_settings == null || var.web_app_config.auth_settings.microsoft == null || (var.web_app_config.auth_settings.microsoft.client_id != null && var.web_app_config.auth_settings.microsoft.client_id != "")
    error_message = "auth_settings.microsoft.client_id is required when using Microsoft Account login."
  }

  validation {
    condition     = var.web_app_config.auth_settings == null || var.web_app_config.auth_settings.twitter == null || (var.web_app_config.auth_settings.twitter.consumer_key != null && var.web_app_config.auth_settings.twitter.consumer_key != "")
    error_message = "auth_settings.twitter.consumer_key is required when using Twitter login."
  }

  validation {
    condition = (
      var.web_app_config.auth_settings == null ||
      var.web_app_config.auth_settings.active_directory == null ||
      !(var.web_app_config.auth_settings.active_directory.client_secret != null && var.web_app_config.auth_settings.active_directory.client_secret_setting_name != null)
    )
    error_message = "Only one of active_directory.client_secret or client_secret_setting_name may be set."
  }

  # Auth Settings (V2)

  validation {
    condition = (
      var.web_app_config.auth_settings_v2 == null ||
      var.web_app_config.auth_settings_v2.identity_providers == null ||
      length(distinct([for idp in var.web_app_config.auth_settings_v2.identity_providers : idp.provider if idp.provider == "OpenIDConnect"])) == length([for idp in var.web_app_config.auth_settings_v2.identity_providers : idp.provider if idp.provider == "OpenIDConnect"])
    )
    error_message = "Custom OpenID Connect provider names in auth_settings_v2.identity_providers must be unique."
  }

  validation {
    condition = (
      var.web_app_config.auth_settings_v2 == null ||
      var.web_app_config.auth_settings_v2.login == null ||
      var.web_app_config.auth_settings_v2.login.token_store_path == null ||
      startswith(var.web_app_config.auth_settings_v2.login.token_store_path, "/")
    )
    error_message = "auth_settings_v2.login.token_store_path must start with '/' if provided."
  }

  validation {
    condition = (
      var.web_app_config.auth_settings_v2 == null ||
      var.web_app_config.auth_settings_v2.login == null ||
      var.web_app_config.auth_settings_v2.login.token_store_sas_setting_name == null ||
      trim(var.web_app_config.auth_settings_v2.login.token_store_sas_setting_name, " ") != ""
    )
    error_message = "auth_settings_v2.login.token_store_sas_setting_name must be a non-empty string if provided."
  }

  validation {
    condition = (
      var.web_app_config.auth_settings_v2 == null ||
      var.web_app_config.auth_settings_v2.login == null ||
      var.web_app_config.auth_settings_v2.login.allowed_external_redirect_urls == null ||
      alltrue([for url in var.web_app_config.auth_settings_v2.login.allowed_external_redirect_urls : can(regex("^https?://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?$", url))])
    )
    error_message = "auth_settings_v2.login.allowed_external_redirect_urls must contain valid URLs (e.g., 'https://example.com')."
  }

  validation {
    condition = (
      var.web_app_config.auth_settings_v2 == null ||
      var.web_app_config.auth_settings_v2.login == null ||
      var.web_app_config.auth_settings_v2.login.logout_endpoint == null ||
      can(regex("^/[a-zA-Z0-9._~-]+$", var.web_app_config.auth_settings_v2.login.logout_endpoint))
    )
    error_message = "auth_settings_v2.login.logout_endpoint must be a valid relative path starting with '/' (e.g., '/logout')."
  }



  validation {
    condition     = var.web_app_config.auth_settings_v2 == null || var.web_app_config.auth_settings_v2.default_provider == null || contains(["AzureActiveDirectory", "Facebook", "Google", "MicrosoftAccount", "Twitter", "Github"], var.web_app_config.auth_settings_v2.default_provider)
    error_message = "auth_settings_v2.default_provider must be one of 'AzureActiveDirectory', 'Facebook', 'Google', 'MicrosoftAccount', 'Twitter', or 'Github'."
  }

  validation {
    condition     = var.web_app_config.auth_settings_v2 == null || var.web_app_config.auth_settings_v2.unauthenticated_action == null || contains(["RedirectToLoginPage", "AllowAnonymous"], var.web_app_config.auth_settings_v2.unauthenticated_action)
    error_message = "auth_settings_v2.unauthenticated_action must be 'RedirectToLoginPage' or 'AllowAnonymous'."
  }

  validation {
    condition     = var.web_app_config.auth_settings_v2 == null || !var.web_app_config.auth_settings_v2.require_authentication || var.web_app_config.auth_settings_v2.unauthenticated_action == "RedirectToLoginPage"
    error_message = "If auth_settings_v2.require_authentication is true, unauthenticated_action must be 'RedirectToLoginPage'."
  }

  validation {
    condition     = var.web_app_config.auth_settings_v2 == null || var.web_app_config.auth_settings_v2.forward_proxy_convention == null || contains(["NoProxy", "Standard", "Custom"], var.web_app_config.auth_settings_v2.forward_proxy_convention)
    error_message = "auth_settings_v2.forward_proxy_convention must be 'NoProxy', 'Standard', or 'Custom'."
  }

  validation {
    condition     = var.web_app_config.auth_settings_v2 == null || var.web_app_config.auth_settings_v2.cookie_expiration_convention == null || contains(["FixedTime", "IdentityProviderDerived"], var.web_app_config.auth_settings_v2.cookie_expiration_convention)
    error_message = "auth_settings_v2.cookie_expiration_convention must be 'FixedTime' or 'IdentityProviderDerived'."
  }

  validation {
    condition     = var.web_app_config.auth_settings_v2 == null || var.web_app_config.auth_settings_v2.cookie_expiration_convention != "FixedTime" || var.web_app_config.auth_settings_v2.cookie_expiration_time != null
    error_message = "When auth_settings_v2.cookie_expiration_convention is 'FixedTime', you must set cookie_expiration_time."
  }

  validation {
    condition     = var.web_app_config.auth_settings_v2 == null || var.web_app_config.auth_settings_v2.cookie_expiration_convention != "IdentityProviderDerived" || var.web_app_config.auth_settings_v2.cookie_expiration_time == null
    error_message = "auth_settings_v2.cookie_expiration_time should not be set when cookie_expiration_convention is 'IdentityProviderDerived'."
  }

  validation {
    condition     = var.web_app_config.auth_settings_v2 == null || var.web_app_config.auth_settings_v2.cookie_expiration_time == null || can(regex("^[0-9]{2}:[0-9]{2}:[0-9]{2}$", var.web_app_config.auth_settings_v2.cookie_expiration_time))
    error_message = "auth_settings_v2.cookie_expiration_time must be in the format hh:mm:ss."
  }

  validation {
    condition     = var.web_app_config.auth_settings_v2 == null || var.web_app_config.auth_settings_v2.nonce_expiration_time == null || can(regex("^[0-9]{2}:[0-9]{2}:[0-9]{2}$", var.web_app_config.auth_settings_v2.nonce_expiration_time))
    error_message = "auth_settings_v2.nonce_expiration_time must be in the format hh:mm:ss."
  }

  # Validate tenant_auth_endpoint format for active_directory_v2
  validation {
    condition = (
      var.web_app_config.auth_settings_v2 == null ||
      var.web_app_config.auth_settings_v2.active_directory_v2 == null ||
      var.web_app_config.auth_settings_v2.active_directory_v2.tenant_auth_endpoint == null ||
      can(regex("^https://login.microsoftonline.com/.*/v2.0$", var.web_app_config.auth_settings_v2.active_directory_v2.tenant_auth_endpoint))
    )
    error_message = "active_directory_v2.tenant_auth_endpoint must be a valid Azure AD endpoint (e.g., 'https://login.microsoftonline.com/{tenant-id}/v2.0')."
  }

  validation {
    condition = (
      var.web_app_config.auth_settings_v2 == null ||
      var.web_app_config.auth_settings_v2.active_directory_v2 == null ||
      var.web_app_config.auth_settings_v2.active_directory_v2.client_secret_certificate_thumbprint == null ||
      can(regex("^[0-9a-fA-F]{40}$", var.web_app_config.auth_settings_v2.active_directory_v2.client_secret_certificate_thumbprint))
    )
    error_message = "active_directory_v2.client_secret_certificate_thumbprint must be a 40-character hexadecimal string if provided."
  }

  # Validate openid_configuration_endpoint for custom_oidc_v2
  validation {
    condition = (
      var.web_app_config.auth_settings_v2 == null ||
      var.web_app_config.auth_settings_v2.identity_providers == null ||
      alltrue([for idp in var.web_app_config.auth_settings_v2.identity_providers : idp.openid_configuration_endpoint == null || can(regex("^https://.*$", idp.openid_configuration_endpoint))])
    )
    error_message = "identity_providers.openid_configuration_endpoint must be a valid HTTPS URL."
  }

  # Identity Configuration

  validation {
    condition = (
      var.web_app_config.auth_settings_v2 == null ||
      var.web_app_config.auth_settings_v2.identity_providers == null ||
      alltrue([for idp in var.web_app_config.auth_settings_v2.identity_providers : idp.login_scopes == null || alltrue([for scope in idp.login_scopes : trim(scope, " ") != ""])])
    )
    error_message = "auth_settings_v2.identity_providers.login_scopes must contain non-empty strings."
  }


  validation {
    condition = (
      var.web_app_config.identity == null ||
      var.web_app_config.identity.identity_ids == null ||
      alltrue([for id in var.web_app_config.identity.identity_ids : can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.ManagedIdentity/userAssignedIdentities/.*$", id))])
    )
    error_message = "Each identity.identity_ids must be a valid user-assigned managed identity resource ID."
  }
  validation {
    condition     = var.web_app_config.identity == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned", "SystemAssigned,UserAssigned"], var.web_app_config.identity.type)
    error_message = "Invalid identity type: must be one of 'SystemAssigned', 'UserAssigned', or 'SystemAssigned, UserAssigned'."
  }

  validation {
    condition     = var.web_app_config.identity == null || !contains(["UserAssigned", "SystemAssigned, UserAssigned", "SystemAssigned,UserAssigned"], var.web_app_config.identity.type) || (var.web_app_config.identity.identity_ids != null && length(var.web_app_config.identity.identity_ids) > 0)
    error_message = "When identity.type includes 'UserAssigned', at least one identity_ids must be provided."
  }

  validation {
    condition     = var.web_app_config.identity == null || (var.web_app_config.identity.identity_ids == null || length(var.web_app_config.identity.identity_ids) == 0) || contains(["UserAssigned", "SystemAssigned, UserAssigned", "SystemAssigned,UserAssigned"], var.web_app_config.identity.type)
    error_message = "identity.identity_ids is set, but identity.type is not 'UserAssigned' or 'SystemAssigned, UserAssigned'."
  }

  validation {
    condition     = var.web_app_config.slots == null || length([for slot in var.web_app_config.slots : slot if slot.identity != null && !contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned", "SystemAssigned,UserAssigned"], slot.identity.type)]) == 0
    error_message = "slots.identity.type must be 'SystemAssigned', 'UserAssigned', or 'SystemAssigned, UserAssigned'."
  }

  validation {
    condition     = var.web_app_config.slots == null || length([for slot in var.web_app_config.slots : slot if slot.identity != null && contains(["UserAssigned", "SystemAssigned, UserAssigned", "SystemAssigned,UserAssigned"], slot.identity.type) && (slot.identity.identity_ids == null || length(slot.identity.identity_ids) == 0)]) == 0
    error_message = "Each slot with identity.type including 'UserAssigned' must have at least one identity_ids."
  }

  validation {
    condition     = var.web_app_config.slots == null || length([for slot in var.web_app_config.slots : slot if slot.identity != null && slot.identity.identity_ids != null && length(slot.identity.identity_ids) > 0 && !contains(["UserAssigned", "SystemAssigned, UserAssigned", "SystemAssigned,UserAssigned"], slot.identity.type)]) == 0
    error_message = "slots.identity_ids provided, but identity.type for that slot does not include 'UserAssigned'."
  }

  validation {
    condition = (
      var.web_app_config.auth_settings_v2 == null ||
      var.web_app_config.auth_settings_v2.identity_providers == null ||
      alltrue([for idp in var.web_app_config.auth_settings_v2.identity_providers : contains(["AzureActiveDirectory", "Facebook", "Google", "MicrosoftAccount", "Twitter", "Github", "Apple", "OpenIDConnect"], idp.provider)])
    )
    error_message = "Each auth_settings_v2.identity_providers[].provider must be one of 'AzureActiveDirectory', 'Facebook', 'Google', 'MicrosoftAccount', 'Twitter', 'Github', 'Apple', or 'OpenIDConnect'."
  }

  # Client Certificate Settings
  validation {
    condition = (
      var.web_app_config.client_certificate_enabled == false ||
      var.web_app_config.client_certificate_mode != null
    )
    error_message = "If client_certificate_enabled is true, then client_certificate_mode must be set."
  }

  validation {
    condition     = (var.web_app_config.client_certificate_mode == null || contains(["Required", "Optional", "OptionalInteractiveUser"], var.web_app_config.client_certificate_mode))
    error_message = "client_certificate_mode must be one of 'Required', 'Optional', or 'OptionalInteractiveUser'."
  }

  validation {
    condition = (
      var.web_app_config.client_certificate_mode == null ||
      var.web_app_config.client_certificate_enabled != false
    )
    error_message = "client_certificate_mode cannot be set unless client_certificate_enabled is true."
  }

  validation {
    condition = (
      var.web_app_config.client_certificate_exclusion_paths == null ||
      can(regex("^(/[a-zA-Z0-9._~-]+)+$", var.web_app_config.client_certificate_exclusion_paths))
    )
    error_message = "client_certificate_exclusion_paths must be a valid path (e.g., /healthz)."
  }

  validation {
    condition = (
      var.web_app_config.client_certificate_mode == null ||
      var.web_app_config.client_certificate_enabled == true
    )
    error_message = "client_certificate_mode must not be set unless client_certificate_enabled is true."
  }

  # Deployment Slots

  validation {
    condition = (
      var.web_app_config.slots == null ||
      var.web_app_config.service_plan == null ||
      !contains(["F1", "D1", "Y1"], var.web_app_config.service_plan.sku_name)
    )
    error_message = "Deployment slots are not supported on Free (F1), Shared (D1), or Function (Y1) SKUs."
  }
  validation {
    condition     = var.web_app_config.slots == null || alltrue([for s in var.web_app_config.slots : s.name != var.web_app_config.name])
    error_message = "A deployment slot cannot have the same name as the main web app."
  }

  validation {
    condition     = var.web_app_config.slots == null || length(distinct([for s in var.web_app_config.slots : s.name])) == length(var.web_app_config.slots)
    error_message = "Deployment slot names must be unique."
  }

  validation {
    condition     = var.web_app_config.slots == null || alltrue([for s in var.web_app_config.slots : can(regex("^[a-zA-Z0-9-]+$", s.name))])
    error_message = "Each slot name must be alphanumeric and may include dashes only."
  }

  validation {
    condition = (
      var.web_app_config.slots == null ||
      alltrue(flatten([for s in var.web_app_config.slots : s.app_settings == null ? [true] : [length(distinct(keys(s.app_settings))) == length(keys(s.app_settings))]]))
    )
    error_message = "Slot app_settings must not contain duplicate keys."
  }

  validation {
    condition = (
      var.web_app_config.slots == null ||
      alltrue(flatten([for s in var.web_app_config.slots : s.app_settings == null ? [true] : [length([for k in keys(s.app_settings) : k if trim(k, " ") == ""]) == 0]]))
    )
    error_message = "Slot app setting keys must not be empty."
  }

  validation {
    condition = (
      var.web_app_config.slots == null ||
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.auto_swap_slot_name == null ||
      contains([for s in var.web_app_config.slots : s.name], var.web_app_config.site_config.auto_swap_slot_name)
    )
    error_message = "site_config.auto_swap_slot_name must match the name of a defined slot."
  }

  validation {
    condition = (
      var.web_app_config.slots == null ||
      alltrue([for s in var.web_app_config.slots : length(s.name) >= 1 && length(s.name) <= 59])
    )
    error_message = "Each slot name must be between 1 and 59 characters."
  }

  validation {
    condition = (
      var.web_app_config.slots == null ||
      alltrue([for s in var.web_app_config.slots : s.sticky_settings == null || s.app_settings == null || alltrue([for sticky in try(s.sticky_settings.app_setting_names, []) : contains(keys(s.app_settings), sticky)])])
    )
    error_message = "Each sticky_settings.app_setting_name must exist in slot app_settings."
  }

  validation {
    condition = (
      var.web_app_config.slots == null ||
      alltrue(flatten([for s in var.web_app_config.slots : s.connection_string == null ? [true] : [for cs in s.connection_string : contains(["APIHub", "Custom", "DocDb", "EventHub", "MySQL", "NotificationHub", "PostgreSQL", "RedisCache", "ServiceBus", "SQLAzure", "SQLServer"], cs.type)]]))
    )
    error_message = "Each slot.connection_string.type must be one of the documented values (e.g., SQLAzure, PostgreSQL, etc.)."
  }

  validation {
    condition = (
      var.web_app_config.slots == null ||
      alltrue([for s in var.web_app_config.slots : s.name != var.web_app_config.name])
    )
    error_message = "A deployment slot cannot have the same name as the main web app."
  }

  validation {
    condition = (
      var.web_app_config.slots == null ||
      alltrue([for s in var.web_app_config.slots : can(regex("^[a-zA-Z0-9-]+$", s.name))])
    )
    error_message = "Each slot name must be alphanumeric and may include dashes only."
  }

  validation {
    condition = (
      var.web_app_config.slots == null ||
      alltrue([for s in var.web_app_config.slots : s.logs == null || (s.logs.application_logs == null || s.logs.application_logs.file_system_level != null)])
    )
    error_message = "If slot.logs.application_logs is defined, file_system_level must be specified."
  }

  validation {
    condition = (
      var.web_app_config.slots == null ||
      alltrue(flatten([for slot in var.web_app_config.slots : slot.app_settings == null ? [true] : [for v in values(slot.app_settings) : trim(v) != ""]]))
    )
    error_message = "Each slot app_setting value must be a non-empty string."
  }

  validation {
    condition = (
      var.web_app_config.slots != null ||
      var.web_app_config.site_config == null ||
      var.web_app_config.site_config.auto_swap_slot_name == null
    )
    error_message = "site_config.auto_swap_slot_name must not be set if no slots are defined."
  }

  validation {
    condition     = var.web_app_config.slots == null || alltrue([for s in var.web_app_config.slots : s.service_plan_id == null || can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.Web/serverfarms/.+$", s.service_plan_id))])
    error_message = "Each slot.service_plan_id must be a valid App Service Plan resource ID if provided."
  }

  validation {
    condition     = var.web_app_config.slots == null || alltrue([for s in var.web_app_config.slots : s.site_config == null || s.site_config.always_on == null || s.service_plan_id == null || !contains(["F1", "D1"], lookup(var.web_app_config.service_plan, "sku_name", var.web_app_config.service_plan_id != null ? "unknown" : var.web_app_config.service_plan.sku_name)) || s.site_config.always_on == false])
    error_message = "slot.site_config.always_on must be false when using Free (F1) or Shared (D1) SKUs."
  }

  # Slot Site Config

  validation {
    condition = (
      var.web_app_config.slots == null ||
      var.web_app_config.app_settings == null ||
      alltrue([for s in var.web_app_config.slots : s.app_settings == null || length(setintersection(keys(var.web_app_config.app_settings), keys(s.app_settings))) == 0])
    )
    error_message = "Slot app_settings should not duplicate main web_app_config.app_settings keys to avoid unexpected overrides; use sticky_settings if intentional."
  }

  validation {
    condition = (
      var.web_app_config.site_config.auto_swap_slot_name == null ||
      trim(var.web_app_config.site_config.auto_swap_slot_name, " ") != ""
    )
    error_message = "site_config.auto_swap_slot_name must be a non-empty string if provided."
  }
  validation {
    condition     = var.web_app_config.slots == null || length([for slot in var.web_app_config.slots : slot if slot.site_config != null && slot.site_config.application_stack != null && slot.site_config.application_stack.node_version != null && slot.site_config.application_stack.java_version != null]) == 0
    error_message = "slots.application_stack: node_version and java_version cannot both be set for a slot."
  }

  validation {
    condition = (
      var.web_app_config.slots == null ||
      alltrue([for s in var.web_app_config.slots : s.logs == null || s.logs.application_logs == null || s.logs.application_logs.azure_blob_storage == null || contains(["Verbose", "Information", "Warning", "Error"], s.logs.application_logs.azure_blob_storage.level)])
    )
    error_message = "slots.logs.application_logs.azure_blob_storage.level must be one of 'Verbose', 'Information', 'Warning', or 'Error'."
  }

  validation {
    condition     = var.web_app_config.slots == null || length(flatten([for slot in var.web_app_config.slots : [for rule in try(slot.site_config.ip_restriction, []) : rule if(((rule.ip_address != null ? 1 : 0) + (rule.service_tag != null ? 1 : 0) + (rule.virtual_network_subnet_id != null ? 1 : 0)) != 1)]])) == 0
    error_message = "Each slots.site_config.ip_restriction must specify exactly one of ip_address, service_tag, or virtual_network_subnet_id."
  }

  validation {
    condition     = var.web_app_config.slots == null || length(flatten([for slot in var.web_app_config.slots : [for rule in try(slot.site_config.ip_restriction, []) : rule if rule.action != null && !contains(["Allow", "Deny"], rule.action)]])) == 0
    error_message = "slots.site_config.ip_restriction.action must be 'Allow' or 'Deny' if specified."
  }

  validation {
    condition     = var.web_app_config.slots == null || length(flatten([for slot in var.web_app_config.slots : [for rule in try(slot.site_config.ip_restriction, []) : rule if rule.priority != null && (rule.priority < 100 || rule.priority > 65535)]])) == 0
    error_message = "slots.site_config.ip_restriction.priority must be between 100 and 65535."
  }

  validation {
    condition = (
      var.web_app_config.slots == null || length([for s in var.web_app_config.slots : s.site_config.auto_heal_setting.actions if s.site_config != null && s.site_config.auto_heal_setting != null && s.site_config.auto_heal_setting.actions != null && !contains(["Recycle", "LogEvent", "CustomAction"], s.site_config.auto_heal_setting.actions.action_type)]) == 0
    )
    error_message = "Each slot.site_config.auto_heal_setting.actions.action_type must be one of 'Recycle', 'LogEvent', or 'CustomAction'."
  }

  validation {
    condition = (
      var.web_app_config.site_config.auto_heal_setting == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers.slow_request == null ||
      can(regex("^[0-9]+[smh]$", var.web_app_config.site_config.auto_heal_setting.triggers.slow_request.time_taken))
    )
    error_message = "auto_heal_setting.triggers.slow_request.time_taken must be in the format 'Xs', 'Xm', or 'Xh' (e.g., '30s', '5m')."
  }

  validation {
    condition = (
      var.web_app_config.site_config.auto_heal_setting == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers.slow_request == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers.slow_request.count > 0
    )
    error_message = "auto_heal_setting.triggers.slow_request.count must be a positive integer."
  }

  validation {
    condition = (
      var.web_app_config.site_config.auto_heal_setting == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers.requests == null ||
      can(regex("^[0-9]+[smh]$", var.web_app_config.site_config.auto_heal_setting.triggers.requests.interval))
    )
    error_message = "auto_heal_setting.triggers.requests.interval must be in the format 'Xs', 'Xm', or 'Xh' (e.g., '30s', '5m')."
  }

  validation {
    condition = (
      var.web_app_config.site_config.auto_heal_setting == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers.requests == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers.requests.count > 0
    )
    error_message = "auto_heal_setting.triggers.requests.count must be a positive integer."
  }

  validation {
    condition = (
      var.web_app_config.site_config.auto_heal_setting == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers.status_code == null ||
      alltrue([for sc in var.web_app_config.site_config.auto_heal_setting.triggers.status_code : can(regex("^[0-9]+[smh]$", sc.interval))])
    )
    error_message = "auto_heal_setting.triggers.status_code.interval must be in the format 'Xs', 'Xm', or 'Xh' (e.g., '30s', '5m')."
  }

  validation {
    condition = (
      var.web_app_config.site_config.auto_heal_setting == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers.status_code == null ||
      alltrue([for sc in var.web_app_config.site_config.auto_heal_setting.triggers.status_code : sc.count > 0])
    )
    error_message = "auto_heal_setting.triggers.status_code.count must be a positive integer."
  }

  validation {
    condition = (
      var.web_app_config.site_config.auto_heal_setting == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers.status_code == null ||
      alltrue([for sc in var.web_app_config.site_config.auto_heal_setting.triggers.status_code : sc.path == null || startswith(sc.path, "/")])
    )
    error_message = "auto_heal_setting.triggers.status_code.path must start with '/' if provided."
  }

  validation {
    condition = (
      var.web_app_config.site_config.auto_heal_setting == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers.status_code == null ||
      alltrue([for sc in var.web_app_config.site_config.auto_heal_setting.triggers.status_code : sc.sub_status == null || (sc.sub_status >= 0 && sc.sub_status <= 999)])
    )
    error_message = "auto_heal_setting.triggers.status_code.sub_status must be between 0 and 999 if provided."
  }
  validation {
    condition = (
      var.web_app_config.site_config.auto_heal_setting == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers.slow_request == null ||
      can(regex("^[0-9]+[smh]$", var.web_app_config.site_config.auto_heal_setting.triggers.slow_request.interval))
    )
    error_message = "auto_heal_setting.triggers.slow_request.interval must be in the format 'Xs', 'Xm', or 'Xh' (e.g., '30s', '5m')."
  }

  validation {
    condition = (
      var.web_app_config.site_config.auto_heal_setting == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers == null ||
      var.web_app_config.site_config.auto_heal_setting.triggers.status_code == null ||
      alltrue([for sc in var.web_app_config.site_config.auto_heal_setting.triggers.status_code : sc.win32_status_code == null || (sc.win32_status_code >= 0 && sc.win32_status_code <= 4294967295)])
    )
    error_message = "auto_heal_setting.triggers.status_code.win32_status_code must be between 0 and 4294967295 if provided."
  }

  validation {
    condition = (
      var.web_app_config.site_config.auto_heal_setting == null ||
      var.web_app_config.site_config.auto_heal_setting.actions == null ||
      var.web_app_config.site_config.auto_heal_setting.actions.minimum_process_execution_time == null ||
      can(regex("^[0-9]{2}:[0-9]{2}:[0-9]{2}$", var.web_app_config.site_config.auto_heal_setting.actions.minimum_process_execution_time))
    )
    error_message = "auto_heal_setting.actions.minimum_process_execution_time must be in the format 'hh:mm:ss' (e.g., '00:05:00')."
  }

  validation {
    condition = (
      var.web_app_config.slots == null || alltrue(flatten([for s in var.web_app_config.slots : s.app_settings == null ? [true] : [for v in values(s.app_settings) : trim(v) != ""]]))
    )
    error_message = "Each slot app_setting value must be a non-empty string."
  }

  # Validate maximum number of slots (Azure limit: 20 for Premium)
  validation {
    condition = (
      var.web_app_config.slots == null ||
      length(var.web_app_config.slots) <= 20
    )
    error_message = "The number of slots must not exceed 20, per Azure's Premium tier limit."
  }

  # Validate slot-specific client_certificate_exclusion_paths
  validation {
    condition = (
      var.web_app_config.slots == null ||
      alltrue([for s in var.web_app_config.slots : s.client_certificate_exclusion_paths == null || can(regex("^(/[a-zA-Z0-9._~-]+)+$", s.client_certificate_exclusion_paths))])
    )
    error_message = "Each slot.client_certificate_exclusion_paths must be a valid path (e.g., /healthz)."
  }

  # Timeouts

  validation {
    condition = (
      var.web_app_config.timeouts == null ||
      (
        (var.web_app_config.timeouts.create == null || (
          can(regex("^[0-9]+[smhd]$", var.web_app_config.timeouts.create)) &&
          try(
            tonumber(regex("^[0-9]+", var.web_app_config.timeouts.create)[0]) * (
              endswith(var.web_app_config.timeouts.create, "s") ? 1 :
              endswith(var.web_app_config.timeouts.create, "m") ? 60 :
              endswith(var.web_app_config.timeouts.create, "h") ? 3600 :
              endswith(var.web_app_config.timeouts.create, "d") ? 86400 : 0
            ),
            0
          ) <= 7200
        )) &&
        (var.web_app_config.timeouts.update == null || (
          can(regex("^[0-9]+[smhd]$", var.web_app_config.timeouts.update)) &&
          try(
            tonumber(regex("^[0-9]+", var.web_app_config.timeouts.update)[0]) * (
              endswith(var.web_app_config.timeouts.update, "s") ? 1 :
              endswith(var.web_app_config.timeouts.update, "m") ? 60 :
              endswith(var.web_app_config.timeouts.update, "h") ? 3600 :
              endswith(var.web_app_config.timeouts.update, "d") ? 86400 : 0
            ),
            0
          ) <= 7200
        )) &&
        (var.web_app_config.timeouts.delete == null || (
          can(regex("^[0-9]+[smhd]$", var.web_app_config.timeouts.delete)) &&
          try(
            tonumber(regex("^[0-9]+", var.web_app_config.timeouts.delete)[0]) * (
              endswith(var.web_app_config.timeouts.delete, "s") ? 1 :
              endswith(var.web_app_config.timeouts.delete, "m") ? 60 :
              endswith(var.web_app_config.timeouts.delete, "h") ? 3600 :
              endswith(var.web_app_config.timeouts.delete, "d") ? 86400 : 0
            ),
            0
          ) <= 7200
        ))
      )
    )
    error_message = "Timeouts (create, update, delete) must use a valid duration format (e.g., '30m', '1h') and not exceed 7200 seconds (2 hours)."
  }

  # Tags
  validation {
    condition     = var.web_app_config.tags == null || alltrue([for k in keys(var.web_app_config.tags) : trim(k) != ""])
    error_message = "Each tag key must be a non-empty string."
  }

  # Validate tag key length and characters
  validation {
    condition = (
      var.web_app_config.tags == null ||
      alltrue([for k in keys(var.web_app_config.tags) : length(k) <= 512 && can(regex("^[a-zA-Z0-9-_ ]+$", k))])
    )
    error_message = "Tag keys must be 1-512 characters and contain only letters, numbers, spaces, hyphens, or underscores."
  }

  # Validate tag value length
  validation {
    condition = (
      var.web_app_config.tags == null ||
      alltrue([for v in values(var.web_app_config.tags) : length(v) <= 256])
    )
    error_message = "Tag values must be 0-256 characters."
  }

  # Miscellaneous
  validation {
    condition = (
      var.web_app_config.zip_deploy_file == null ||
      can(regex(".*\\.zip$", var.web_app_config.zip_deploy_file))
    )
    error_message = "zip_deploy_file must be a .zip file if provided."
  }

  validation {
    condition = (
      var.web_app_config.virtual_network_subnet_id == null ||
      can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.Network/virtualNetworks/.*/subnets/.*$", var.web_app_config.virtual_network_subnet_id))
    )
    error_message = "virtual_network_subnet_id must be a valid subnet resource ID."
  }

  validation {
    condition = (
      var.web_app_config.key_vault_reference_identity_id == null ||
      can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.ManagedIdentity/userAssignedIdentities/.*$", var.web_app_config.key_vault_reference_identity_id))
    )
    error_message = "key_vault_reference_identity_id must be a valid resource ID of a user-assigned managed identity."
  }

  validation {
    condition = (
      var.web_app_config.public_network_access_enabled == null ||
      var.web_app_config.public_network_access_enabled == true ||
      var.web_app_config.site_config != null
    )
    error_message = "public_network_access_enabled=false requires site_config to be defined (needed for VNet integration)."
  }

  validation {
    condition = (
      var.web_app_config.zip_deploy_file == null ||
      var.web_app_config.app_settings == null ||
      lookup(var.web_app_config.app_settings, "WEBSITE_RUN_FROM_PACKAGE", "0") == "1" ||
      lookup(var.web_app_config.app_settings, "SCM_DO_BUILD_DURING_DEPLOYMENT", "false") == "true"
    )
    error_message = "zip_deploy_file requires WEBSITE_RUN_FROM_PACKAGE=1 or SCM_DO_BUILD_DURING_DEPLOYMENT=true in app_settings."
  }

  validation {
    condition = (
      var.web_app_config.webdeploy_publish_basic_authentication_enabled == null ||
      var.web_app_config.webdeploy_publish_basic_authentication_enabled == false ||
      var.web_app_config.zip_deploy_file == null
    )
    error_message = "webdeploy_publish_basic_authentication_enabled=true disables zip_deploy_file; it must be null or unset."
  }

  validation {
    condition = var.web_app_config.slots == null || alltrue([
      for s in var.web_app_config.slots :
      s.virtual_network_subnet_id == null || s.virtual_network_subnet_id == var.web_app_config.virtual_network_subnet_id
    ])
    error_message = "All slots must use the same virtual_network_subnet_id as the main app, or none, due to the one-VNet-per-plan limit."
  }

  validation {
    condition = (
      var.web_app_config.virtual_network_subnet_id == null ||
      contains(split("/", var.web_app_config.virtual_network_subnet_id), var.web_app_config.resource_group_name)
    )
    error_message = "virtual_network_subnet_id must belong to the same resource group as web_app_config.resource_group_name, implying the same region."
  }

 
  validation {
  condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,58}$", var.web_app_config.name))
  error_message = "name must start with an alphanumeric character and be 1-59 characters long using only letters, digits, underscores, hyphens, or periods."
}


  validation {
  condition     = can(regex("^.+$", var.web_app_config.identity))
  error_message = "identity must be a non-empty string."
}

}

