########################
# Main Resource: Azure Linux Web App (with optional settings)
########################

resource "azurerm_service_plan" "this" {
  count               = var.web_app_config.service_plan != null ? 1 : 0
  name                = var.web_app_config.service_plan.name
  location            = var.web_app_config.service_plan.location
  resource_group_name = var.web_app_config.service_plan.resource_group_name
  os_type             = var.web_app_config.service_plan.os_type
  sku_name            = var.web_app_config.service_plan.sku_name
  timeouts {
    create = try(var.web_app_config.timeouts.create, null)
    update = try(var.web_app_config.timeouts.update, null)
    delete = try(var.web_app_config.timeouts.delete, null)

  }


  app_service_environment_id   = try(var.web_app_config.service_plan.app_service_environment_id, null)
  per_site_scaling_enabled     = try(var.web_app_config.service_plan.per_site_scaling_enabled, false)
  zone_balancing_enabled       = try(var.web_app_config.service_plan.zone_balancing_enabled, null)
  maximum_elastic_worker_count = try(var.web_app_config.service_plan.maximum_elastic_worker_count, null)
  worker_count                 = try(var.web_app_config.service_plan.worker_count, null)

  tags = var.tags
}


resource "azurerm_linux_web_app" "this" {
  name                = var.web_app_config.name
  resource_group_name = var.web_app_config.resource_group_name
  location            = var.web_app_config.location
  service_plan_id     = var.web_app_config.service_plan != null ? azurerm_service_plan.this[0].id : var.web_app_config.service_plan_id

  https_only                                     = var.web_app_config.https_only != null ? var.web_app_config.https_only : false
  client_affinity_enabled                        = var.web_app_config.client_affinity_enabled != null ? var.web_app_config.client_affinity_enabled : true
  enabled                                        = var.web_app_config.enabled != null ? var.web_app_config.enabled : true
  webdeploy_publish_basic_authentication_enabled = var.web_app_config.webdeploy_publish_basic_authentication_enabled != null ? var.web_app_config.webdeploy_publish_basic_authentication_enabled : false
  zip_deploy_file                                = var.web_app_config.zip_deploy_file != null ? var.web_app_config.zip_deploy_file : null
  key_vault_reference_identity_id                = var.web_app_config.key_vault_reference_identity_id != null ? var.web_app_config.key_vault_reference_identity_id : null
  ftp_publish_basic_authentication_enabled       = var.web_app_config.ftp_publish_basic_authentication_enabled != null ? var.web_app_config.ftp_publish_basic_authentication_enabled : true
  public_network_access_enabled                  = var.web_app_config.public_network_access_enabled != null ? var.web_app_config.public_network_access_enabled : true
  client_certificate_exclusion_paths             = var.web_app_config.client_certificate_exclusion_paths != null ? var.web_app_config.client_certificate_exclusion_paths : null
  virtual_network_subnet_id                      = try(var.web_app_config.virtual_network_subnet_id, null)

  timeouts {
    create = try(var.web_app_config.timeouts.create, null)
    update = try(var.web_app_config.timeouts.update, null)
    delete = try(var.web_app_config.timeouts.delete, null)

  }



  dynamic "identity" {
    for_each = var.web_app_config.identity != null ? [var.web_app_config.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids != null ? identity.value.identity_ids : []
    }
  }

  dynamic "auth_settings" {
    for_each = var.web_app_config.auth_settings != null ? [var.web_app_config.auth_settings] : []
    content {
      enabled                        = lookup(auth_settings.value, "enabled", true)
      default_provider               = lookup(auth_settings.value, "default_provider", null)
      token_refresh_extension_hours  = lookup(auth_settings.value, "token_refresh_extension_hours", null)
      unauthenticated_client_action  = lookup(auth_settings.value, "unauthenticated_client_action", null)
      allowed_external_redirect_urls = lookup(auth_settings.value, "allowed_external_redirect_urls", null)
      runtime_version                = lookup(auth_settings.value, "runtime_version", null)
      token_store_enabled            = lookup(auth_settings.value, "token_store_enabled", false)

      dynamic "active_directory" {
        for_each = lookup(auth_settings.value, "active_directory", null) != null ? [auth_settings.value.active_directory] : []
        content {
          client_id                  = active_directory.value.client_id
          client_secret              = lookup(active_directory.value, "client_secret", null)
          client_secret_setting_name = lookup(active_directory.value, "client_secret_setting_name", null)
          allowed_audiences          = lookup(active_directory.value, "allowed_audiences", null)
        }
      }

      dynamic "facebook" {
        for_each = lookup(auth_settings.value, "facebook", null) != null ? [auth_settings.value.facebook] : []
        content {
          app_id                  = facebook.value.app_id
          app_secret              = lookup(facebook.value, "app_secret", null)
          app_secret_setting_name = lookup(facebook.value, "app_secret_setting_name", null)
        }
      }

      dynamic "github" {
        for_each = lookup(auth_settings.value, "github", null) != null ? [auth_settings.value.github] : []
        content {
          client_id                  = github.value.client_id
          client_secret              = lookup(github.value, "client_secret", null)
          client_secret_setting_name = lookup(github.value, "client_secret_setting_name", null)
        }
      }

      dynamic "google" {
        for_each = lookup(auth_settings.value, "google", null) != null ? [auth_settings.value.google] : []
        content {
          client_id                  = google.value.client_id
          client_secret              = lookup(google.value, "client_secret", null)
          client_secret_setting_name = lookup(google.value, "client_secret_setting_name", null)
        }
      }

      dynamic "microsoft" {
        for_each = lookup(auth_settings.value, "microsoft", null) != null ? [auth_settings.value.microsoft] : []
        content {
          client_id                  = microsoft.value.client_id
          client_secret              = lookup(microsoft.value, "client_secret", null)
          client_secret_setting_name = lookup(microsoft.value, "client_secret_setting_name", null)
        }
      }

      dynamic "twitter" {
        for_each = lookup(auth_settings.value, "twitter", null) != null ? [auth_settings.value.twitter] : []
        content {
          consumer_key                 = twitter.value.consumer_key
          consumer_secret              = lookup(twitter.value, "consumer_secret", null)
          consumer_secret_setting_name = lookup(twitter.value, "consumer_secret_setting_name", null)
        }
      }
    }
  }
  dynamic "auth_settings_v2" {
    for_each = var.web_app_config.auth_settings_v2 != null ? [var.web_app_config.auth_settings_v2] : []
    content {
      auth_enabled             = lookup(auth_settings_v2.value, "auth_enabled", true)
      require_authentication   = lookup(auth_settings_v2.value, "require_authentication", null)
      unauthenticated_action   = lookup(auth_settings_v2.value, "unauthenticated_action", null)
      forward_proxy_convention = lookup(auth_settings_v2.value, "forward_proxy_convention", null)


      dynamic "login" {
        for_each = lookup(auth_settings_v2.value, "login", null) != null ? [auth_settings_v2.value.login] : []
        content {
          token_store_enabled               = lookup(login.value, "token_store_enabled", false)
          token_refresh_extension_time      = lookup(login.value, "token_refresh_extension_time", null)
          token_store_path                  = lookup(login.value, "token_store_path", null)
          token_store_sas_setting_name      = lookup(login.value, "token_store_sas_setting_name", null)
          preserve_url_fragments_for_logins = lookup(login.value, "preserve_url_fragments", false)
          allowed_external_redirect_urls    = lookup(login.value, "allowed_external_redirect_urls", [])
          logout_endpoint                   = lookup(login.value, "logout_endpoint", null)
          cookie_expiration_convention      = lookup(login.value, "cookie_expiration_convention", null)
          cookie_expiration_time            = lookup(login.value, "cookie_expiration_time", null)
          validate_nonce                    = lookup(login.value, "validate_nonce", true)
          nonce_expiration_time             = lookup(login.value, "nonce_expiration_time", null)
        }
      }


      dynamic "active_directory_v2" {
        for_each = lookup(auth_settings_v2.value, "active_directory_v2", null) != null ? [auth_settings_v2.value.active_directory_v2] : []
        content {
          client_id                            = active_directory_v2.value.client_id
          tenant_auth_endpoint                 = lookup(active_directory_v2.value, "tenant_auth_endpoint", null)
          client_secret_setting_name           = lookup(active_directory_v2.value, "client_secret_setting_name", null)
          client_secret_certificate_thumbprint = lookup(active_directory_v2.value, "client_secret_certificate_thumbprint", null)
          jwt_allowed_groups                   = lookup(active_directory_v2.value, "jwt_allowed_groups", null)
          jwt_allowed_client_applications      = lookup(active_directory_v2.value, "jwt_allowed_client_applications", null)
        }
      }

      dynamic "google_v2" {
        for_each = lookup(auth_settings_v2.value, "google_v2", null) != null ? [auth_settings_v2.value.google_v2] : []
        content {
          client_id                  = google_v2.value.client_id
          client_secret_setting_name = google_v2.value.client_secret_setting_name
          allowed_audiences          = lookup(google_v2.value, "allowed_audiences", null)
          login_scopes               = lookup(google_v2.value, "login_scopes", null)
        }
      }

      dynamic "facebook_v2" {
        for_each = lookup(auth_settings_v2.value, "facebook_v2", null) != null ? [auth_settings_v2.value.facebook_v2] : []
        content {
          app_id                  = facebook_v2.value.app_id
          app_secret_setting_name = facebook_v2.value.app_secret_setting_name
          graph_api_version       = lookup(facebook_v2.value, "graph_api_version", null)
          login_scopes            = lookup(facebook_v2.value, "login_scopes", null)
        }
      }

      dynamic "github_v2" {
        for_each = lookup(auth_settings_v2.value, "github_v2", null) != null ? [auth_settings_v2.value.github_v2] : []
        content {
          client_id                  = github_v2.value.client_id
          client_secret_setting_name = github_v2.value.client_secret_setting_name
          login_scopes               = lookup(github_v2.value, "login_scopes", null)
        }
      }

      dynamic "microsoft_v2" {
        for_each = lookup(auth_settings_v2.value, "microsoft_v2", null) != null ? [auth_settings_v2.value.microsoft_v2] : []
        content {
          client_id                  = microsoft_v2.value.client_id
          client_secret_setting_name = microsoft_v2.value.client_secret_setting_name
          allowed_audiences          = lookup(microsoft_v2.value, "allowed_audiences", null)
          login_scopes               = lookup(microsoft_v2.value, "login_scopes", null)
        }
      }

      dynamic "twitter_v2" {
        for_each = lookup(auth_settings_v2.value, "twitter_v2", null) != null ? [auth_settings_v2.value.twitter_v2] : []
        content {
          consumer_key                 = twitter_v2.value.consumer_key
          consumer_secret_setting_name = twitter_v2.value.consumer_secret_setting_name
        }
      }

      dynamic "apple_v2" {
        for_each = lookup(auth_settings_v2.value, "apple_v2", null) != null ? [auth_settings_v2.value.apple_v2] : []
        content {
          client_id                  = apple_v2.value.client_id
          client_secret_setting_name = apple_v2.value.client_secret_setting_name
        }
      }

      dynamic "custom_oidc_v2" {
        for_each = lookup(auth_settings_v2.value, "custom_oidc_v2", [])
        content {
          name                          = custom_oidc_v2.value.name
          client_id                     = custom_oidc_v2.value.client_id
          openid_configuration_endpoint = custom_oidc_v2.value.openid_configuration_endpoint
          client_secret_setting_name    = lookup(custom_oidc_v2.value, "client_secret_setting_name", null)
          name_claim_type               = lookup(custom_oidc_v2.value, "name_claim_type", null)
          scopes                        = lookup(custom_oidc_v2.value, "scopes", null)
        }
      }

      dynamic "azure_static_web_app_v2" {
        for_each = lookup(auth_settings_v2.value, "azure_static_web_app_v2", null) != null ? [auth_settings_v2.value.azure_static_web_app_v2] : []
        content {
          client_id = azure_static_web_app_v2.value.client_id
        }
      }
    }
  }

  site_config {
    always_on                                     = lookup(var.web_app_config.site_config, "always_on", false)
    linux_fx_version                              = lookup(var.web_app_config.site_config, "linux_fx_version", null)
    ftps_state                                    = lookup(var.web_app_config.site_config, "ftps_state", null)
    minimum_tls_version                           = lookup(var.web_app_config.site_config, "minimum_tls_version", null)
    scm_minimum_tls_version                       = lookup(var.web_app_config.site_config, "scm_minimum_tls_version", null)
    remote_debugging_enabled                      = lookup(var.web_app_config.site_config, "remote_debugging_enabled", null)
    remote_debugging_version                      = lookup(var.web_app_config.site_config, "remote_debugging_version", null)
    websockets_enabled                            = lookup(var.web_app_config.site_config, "websockets_enabled", null)
    vnet_route_all_enabled                        = lookup(var.web_app_config.site_config, "vnet_route_all_enabled", null)
    http2_enabled                                 = lookup(var.web_app_config.site_config, "http2_enabled", null)
    health_check_path                             = lookup(var.web_app_config.site_config, "health_check_path", null)
    health_check_eviction_time_in_min             = lookup(var.web_app_config.site_config, "health_check_eviction_time_in_min", null)
    managed_pipeline_mode                         = lookup(var.web_app_config.site_config, "managed_pipeline_mode", null)
    load_balancing_mode                           = lookup(var.web_app_config.site_config, "load_balancing_mode", null)
    app_command_line                              = lookup(var.web_app_config.site_config, "app_command_line", null)
    container_registry_use_managed_identity       = lookup(var.web_app_config.site_config, "container_registry_use_managed_identity", null)
    scm_use_main_ip_restriction                   = lookup(var.web_app_config.site_config, "scm_use_main_ip_restriction", null)
    default_documents                             = lookup(var.web_app_config.site_config, "default_documents", null)
    worker_count                                  = lookup(var.web_app_config.site_config, "number_of_workers", null)
    api_definition_url                            = lookup(var.web_app_config.site_config, "api_definition_url", null)
    api_management_api_id                         = lookup(var.web_app_config.site_config, "api_management_api_id", null)
    container_registry_managed_identity_client_id = lookup(var.web_app_config.site_config, "container_registry_managed_identity_client_id", null)
    ip_restriction_default_action                 = lookup(var.web_app_config.site_config, "ip_restriction_default_action", null)
    scm_ip_restriction_default_action             = lookup(var.web_app_config.site_config, "scm_ip_restriction_default_action", null)
    #api_definition_url = try(web_app_config.site_config.api_definition_url, null)
    #api_management_api_id = try(web_app_config.site_config.api_management_api_id, null)



    dynamic "application_stack" {
      for_each = lookup(var.web_app_config.site_config, "application_stack", null) != null ? [var.web_app_config.site_config.application_stack] : []
      content {
        python_version           = lookup(application_stack.value, "python_version", null)
        node_version             = lookup(application_stack.value, "node_version", null)
        dotnet_version           = lookup(application_stack.value, "dotnet_version", null)
        java_version             = lookup(application_stack.value, "java_version", null)
        java_server              = lookup(application_stack.value, "java_server", null)
        java_server_version      = lookup(application_stack.value, "java_server_version", null)
        php_version              = lookup(application_stack.value, "php_version", null)
        ruby_version             = lookup(application_stack.value, "ruby_version", null)
        docker_image_name        = lookup(application_stack.value, "docker_image_name", null)
        docker_registry_url      = lookup(application_stack.value, "docker_registry_url", null)
        docker_registry_username = lookup(application_stack.value, "docker_registry_username", null)
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = lookup(var.web_app_config.site_config, "scm_ip_restriction", [])
      content {
        name                      = lookup(scm_ip_restriction.value, "name", null)
        ip_address                = lookup(scm_ip_restriction.value, "ip_address", null)
        service_tag               = lookup(scm_ip_restriction.value, "service_tag", null)
        virtual_network_subnet_id = lookup(scm_ip_restriction.value, "virtual_network_subnet_id", null)
        action                    = lookup(scm_ip_restriction.value, "action", null)
        priority                  = lookup(scm_ip_restriction.value, "priority", null)
        dynamic "headers" {
          for_each = lookup(scm_ip_restriction.value, "headers", null) != null ? [scm_ip_restriction.value.headers] : []
          content {
            x_forwarded_for  = lookup(headers.value, "x_forwarded_for", null)
            x_azure_fdid     = lookup(headers.value, "x_azure_fdid", null)
            x_forwarded_host = lookup(headers.value, "x_forwarded_host", null)
          }
        }
      }
    }

    dynamic "auto_heal_setting" {
      for_each = lookup(var.web_app_config.site_config, "auto_heal_setting", null) != null ? [var.web_app_config.site_config.auto_heal_setting] : []
      content {
        dynamic "trigger" {
          for_each = lookup(auto_heal_setting.value, "triggers", null) != null ? [auto_heal_setting.value.triggers] : []
          content {
            dynamic "slow_request" {
              for_each = lookup(trigger.value, "slow_request", null) != null ? [trigger.value.slow_request] : []
              content {
                interval   = slow_request.value.interval
                count      = slow_request.value.count
                time_taken = slow_request.value.time_taken
              }
            }

            dynamic "status_code" {
              for_each = lookup(trigger.value, "status_code", [])
              content {
                status_code_range = status_code.value.status_code_range
                count             = status_code.value.count
                interval          = status_code.value.interval
                path              = lookup(status_code.value, "path", null)
                sub_status        = lookup(status_code.value, "sub_status", null)
                win32_status_code = lookup(status_code.value, "win32_status_code", null)
              }
            }

            dynamic "requests" {
              for_each = lookup(trigger.value, "requests", null) != null ? [trigger.value.requests] : []
              content {
                count    = requests.value.count
                interval = requests.value.interval
              }
            }

          }
        }

        dynamic "action" {
          for_each = lookup(auto_heal_setting.value, "actions", null) != null ? [auto_heal_setting.value.actions] : []
          content {
            action_type                    = action.value.action_type
            minimum_process_execution_time = lookup(action.value, "minimum_process_execution_time", null)
          }
        }
      }
    }
    dynamic "cors" {
      for_each = lookup(var.web_app_config.site_config, "cors", null) != null ? [var.web_app_config.site_config.cors] : []
      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = lookup(cors.value, "support_credentials", false)
      }
    }


    dynamic "ip_restriction" {
      for_each = lookup(var.web_app_config.site_config, "ip_restriction", [])
      content {
        name                      = lookup(ip_restriction.value, "name", null)
        ip_address                = lookup(ip_restriction.value, "ip_address", null)
        service_tag               = lookup(ip_restriction.value, "service_tag", null)
        virtual_network_subnet_id = lookup(ip_restriction.value, "virtual_network_subnet_id", null)
        action                    = lookup(ip_restriction.value, "action", null)
        priority                  = lookup(ip_restriction.value, "priority", null)

        dynamic "headers" {
          for_each = lookup(ip_restriction.value, "headers", null) != null ? [ip_restriction.value.headers] : []
          content {
            x_forwarded_for  = lookup(headers.value, "x_forwarded_for", null)
            x_azure_fdid     = lookup(headers.value, "x_azure_fdid", null)
            x_forwarded_host = lookup(headers.value, "x_forwarded_host", null)

          }
        }
      }
    }
  }

  app_settings = var.web_app_config.app_settings != null ? var.web_app_config.app_settings : {}


  dynamic "connection_string" {
    for_each = var.web_app_config.connection_string != null ? var.web_app_config.connection_string : []
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  dynamic "sticky_settings" {
    for_each = var.web_app_config.sticky_settings != null ? [var.web_app_config.sticky_settings] : []
    content {
      app_setting_names       = lookup(sticky_settings.value, "app_setting_names", [])
      connection_string_names = lookup(sticky_settings.value, "connection_string_names", [])
    }
  }

  dynamic "storage_account" {
    for_each = var.web_app_config.storage_account != null ? var.web_app_config.storage_account : []
    content {
      name         = storage_account.value.name
      account_name = storage_account.value.account_name
      access_key   = storage_account.value.access_key
      share_name   = storage_account.value.share_name
      type         = storage_account.value.type
      mount_path   = lookup(storage_account.value, "mount_path", null)
    }
  }
  client_certificate_enabled = var.web_app_config.client_certificate_enabled != null ? var.web_app_config.client_certificate_enabled : false
  client_certificate_mode    = var.web_app_config.client_certificate_mode != null ? var.web_app_config.client_certificate_mode : "Required"

  dynamic "logs" {
    for_each = var.web_app_config.logs != null ? [var.web_app_config.logs] : []
    content {
      dynamic "application_logs" {
        for_each = lookup(logs.value, "application_logs", null) != null ? [logs.value.application_logs] : []
        content {
          file_system_level = lookup(application_logs.value, "file_system_level", null)
          dynamic "azure_blob_storage" {
            for_each = lookup(application_logs.value, "azure_blob_storage", null) != null ? [application_logs.value.azure_blob_storage] : []
            content {
              level             = lookup(azure_blob_storage.value, "level", null)
              sas_url           = azure_blob_storage.value.sas_url
              retention_in_days = lookup(azure_blob_storage.value, "retention_in_days", null)

            }
          }
        }
      }

      dynamic "http_logs" {
        for_each = lookup(logs.value, "http_logs", null) != null ? [logs.value.http_logs] : []
        content {
          dynamic "file_system" {
            for_each = lookup(http_logs.value, "file_system", null) != null ? [http_logs.value.file_system] : []
            content {
              retention_in_mb   = lookup(file_system.value, "retention_in_mb", null)
              retention_in_days = lookup(file_system.value, "retention_in_days", null)
            }
          }

          dynamic "azure_blob_storage" {
            for_each = lookup(http_logs.value, "azure_blob_storage", null) != null ? [http_logs.value.azure_blob_storage] : []
            content {
              sas_url           = http_logs.value.azure_blob_storage.sas_url
              retention_in_days = lookup(http_logs.value.azure_blob_storage, "retention_in_days", null)
            }
          }
        }
      }
    }
  }

  dynamic "backup" {
    for_each = var.web_app_config.backup != null ? [var.web_app_config.backup] : []
    content {
      name                = backup.value.name
      storage_account_url = backup.value.storage_account_url
      enabled             = lookup(backup.value, "enabled", true)
      schedule {
        frequency_interval       = backup.value.schedule.frequency_interval
        frequency_unit           = backup.value.schedule.frequency_unit
        start_time               = lookup(backup.value.schedule, "start_time", null)
        retention_period_days    = lookup(backup.value.schedule, "retention_period_days", null)
        keep_at_least_one_backup = lookup(backup.value.schedule, "keep_at_least_one_backup", false)
      }
    }
  }


  tags = var.web_app_config.tags
  lifecycle {
    ignore_changes = [
      site_config
    ]
  }

}

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  count          = var.web_app_config.virtual_network_subnet_id != null ? 1 : 0
  app_service_id = azurerm_linux_web_app.this.id
  subnet_id      = var.web_app_config.virtual_network_subnet_id

  depends_on = [azurerm_linux_web_app.this]
}
########################
# Deployment Slots (optional, dynamically created if any provided)
########################

resource "azurerm_linux_web_app_slot" "this" {
  for_each       = var.web_app_config.slots != null ? { for s in var.web_app_config.slots : s.name => s } : {}
  name           = each.value.name
  app_service_id = azurerm_linux_web_app.this.id

  client_affinity_enabled            = each.value.client_affinity_enabled != null ? each.value.client_affinity_enabled : (var.web_app_config.client_affinity_enabled != null ? var.web_app_config.client_affinity_enabled : true)
  https_only                         = each.value.https_only != null ? each.value.https_only : (var.web_app_config.https_only != null ? var.web_app_config.https_only : false)
  enabled                            = lookup(each.value, "enabled", true)
  virtual_network_subnet_id          = var.web_app_config.virtual_network_subnet_id
  client_certificate_exclusion_paths = try(each.value.client_certificate_exclusion_paths, null)


  timeouts {
    create = try(var.web_app_config.timeouts.create, null)
    update = try(var.web_app_config.timeouts.update, null)
    delete = try(var.web_app_config.timeouts.delete, null)

  }



  dynamic "identity" {
    for_each = lookup(each.value, "identity", null) != null ? [each.value.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids != null ? identity.value.identity_ids : []
    }
  }

  dynamic "auth_settings" {
    for_each = lookup(each.value, "auth_settings", null) != null ? [each.value.auth_settings] : []
    content {
      enabled = lookup(auth_settings.value, "enabled", true)

      dynamic "active_directory" {
        for_each = lookup(auth_settings.value, "active_directory", null) != null ? [auth_settings.value.active_directory] : []
        content {
          client_id                  = active_directory.value.client_id
          client_secret_setting_name = lookup(active_directory.value, "client_secret_setting_name", null)
        }
      }

      dynamic "facebook" {
        for_each = lookup(auth_settings.value, "facebook", null) != null ? [auth_settings.value.facebook] : []
        content {
          app_id                  = facebook.value.app_id
          app_secret              = lookup(facebook.value, "app_secret", null)
          app_secret_setting_name = lookup(facebook.value, "app_secret_setting_name", null)
        }
      }

      dynamic "github" {
        for_each = lookup(auth_settings.value, "github", null) != null ? [auth_settings.value.github] : []
        content {
          client_id                  = github.value.client_id
          client_secret              = lookup(github.value, "client_secret", null)
          client_secret_setting_name = lookup(github.value, "client_secret_setting_name", null)
        }
      }

      dynamic "google" {
        for_each = lookup(auth_settings.value, "google", null) != null ? [auth_settings.value.google] : []
        content {
          client_id                  = google.value.client_id
          client_secret              = lookup(google.value, "client_secret", null)
          client_secret_setting_name = lookup(google.value, "client_secret_setting_name", null)
        }
      }

      dynamic "microsoft" {
        for_each = lookup(auth_settings.value, "microsoft", null) != null ? [auth_settings.value.microsoft] : []
        content {
          client_id                  = microsoft.value.client_id
          client_secret              = lookup(microsoft.value, "client_secret", null)
          client_secret_setting_name = lookup(microsoft.value, "client_secret_setting_name", null)
        }
      }

      dynamic "twitter" {
        for_each = lookup(auth_settings.value, "twitter", null) != null ? [auth_settings.value.twitter] : []
        content {
          consumer_key                 = twitter.value.consumer_key
          consumer_secret              = lookup(twitter.value, "consumer_secret", null)
          consumer_secret_setting_name = lookup(twitter.value, "consumer_secret_setting_name", null)
        }
      }

      default_provider = lookup(auth_settings.value, "default_provider", null)
    }
  }

  dynamic "auth_settings_v2" {
    for_each = lookup(each.value, "auth_settings_v2", null) != null ? [each.value.auth_settings_v2] : []
    content {
      auth_enabled = lookup(auth_settings_v2.value, "auth_enabled", true)

      dynamic "login" {
        for_each = lookup(auth_settings_v2.value, "login", null) != null ? [auth_settings_v2.value.login] : []
        content {
          token_store_enabled               = lookup(login.value, "token_store_enabled", false)
          token_refresh_extension_time      = lookup(login.value, "token_refresh_extension_time", null)
          token_store_path                  = lookup(login.value, "token_store_path", null)
          token_store_sas_setting_name      = lookup(login.value, "token_store_sas_setting_name", null)
          preserve_url_fragments_for_logins = lookup(login.value, "preserve_url_fragments", false)
          allowed_external_redirect_urls    = lookup(login.value, "allowed_external_redirect_urls", [])
          logout_endpoint                   = lookup(login.value, "logout_endpoint", null)
          cookie_expiration_convention      = lookup(login.value, "cookie_expiration_convention", null)
          cookie_expiration_time            = lookup(login.value, "cookie_expiration_time", null)
          validate_nonce                    = lookup(login.value, "validate_nonce", true)
          nonce_expiration_time             = lookup(login.value, "nonce_expiration_time", null)
        }
      }

      dynamic "active_directory_v2" {
        for_each = lookup(auth_settings_v2.value, "active_directory_v2", null) != null ? [auth_settings_v2.value.active_directory_v2] : []
        content {
          client_id                            = active_directory_v2.value.client_id
          tenant_auth_endpoint                 = lookup(active_directory_v2.value, "tenant_auth_endpoint", null)
          client_secret_setting_name           = lookup(active_directory_v2.value, "client_secret_setting_name", null)
          client_secret_certificate_thumbprint = lookup(active_directory_v2.value, "client_secret_certificate_thumbprint", null)
          jwt_allowed_groups                   = lookup(active_directory_v2.value, "jwt_allowed_groups", null)
          jwt_allowed_client_applications      = lookup(active_directory_v2.value, "jwt_allowed_client_applications", null)
        }
      }

      dynamic "google_v2" {
        for_each = lookup(auth_settings_v2.value, "google_v2", null) != null ? [auth_settings_v2.value.google_v2] : []
        content {
          client_id                  = google_v2.value.client_id
          client_secret_setting_name = google_v2.value.client_secret_setting_name
          allowed_audiences          = lookup(google_v2.value, "allowed_audiences", null)
          login_scopes               = lookup(google_v2.value, "login_scopes", null)
        }
      }

      dynamic "facebook_v2" {
        for_each = lookup(auth_settings_v2.value, "facebook_v2", null) != null ? [auth_settings_v2.value.facebook_v2] : []
        content {
          app_id                  = facebook_v2.value.app_id
          app_secret_setting_name = facebook_v2.value.app_secret_setting_name
          graph_api_version       = lookup(facebook_v2.value, "graph_api_version", null)
          login_scopes            = lookup(facebook_v2.value, "login_scopes", null)
        }
      }

      dynamic "github_v2" {
        for_each = lookup(auth_settings_v2.value, "github_v2", null) != null ? [auth_settings_v2.value.github_v2] : []
        content {
          client_id                  = github_v2.value.client_id
          client_secret_setting_name = github_v2.value.client_secret_setting_name
          login_scopes               = lookup(github_v2.value, "login_scopes", null)
        }
      }

      dynamic "microsoft_v2" {
        for_each = lookup(auth_settings_v2.value, "microsoft_v2", null) != null ? [auth_settings_v2.value.microsoft_v2] : []
        content {
          client_id                  = microsoft_v2.value.client_id
          client_secret_setting_name = microsoft_v2.value.client_secret_setting_name
          allowed_audiences          = lookup(microsoft_v2.value, "allowed_audiences", null)
          login_scopes               = lookup(microsoft_v2.value, "login_scopes", null)
        }
      }

      dynamic "twitter_v2" {
        for_each = lookup(auth_settings_v2.value, "twitter_v2", null) != null ? [auth_settings_v2.value.twitter_v2] : []
        content {
          consumer_key                 = twitter_v2.value.consumer_key
          consumer_secret_setting_name = twitter_v2.value.consumer_secret_setting_name
        }
      }

      dynamic "apple_v2" {
        for_each = lookup(auth_settings_v2.value, "apple_v2", null) != null ? [auth_settings_v2.value.apple_v2] : []
        content {
          client_id                  = apple_v2.value.client_id
          client_secret_setting_name = apple_v2.value.client_secret_setting_name
        }
      }

      dynamic "custom_oidc_v2" {
        for_each = lookup(auth_settings_v2.value, "custom_oidc_v2", [])
        content {
          name                          = custom_oidc_v2.value.name
          client_id                     = custom_oidc_v2.value.client_id
          openid_configuration_endpoint = custom_oidc_v2.value.openid_configuration_endpoint
          client_secret_setting_name    = lookup(custom_oidc_v2.value, "client_secret_setting_name", null)
          name_claim_type               = lookup(custom_oidc_v2.value, "name_claim_type", null)
          scopes                        = lookup(custom_oidc_v2.value, "scopes", null)
        }
      }

      dynamic "azure_static_web_app_v2" {
        for_each = lookup(auth_settings_v2.value, "azure_static_web_app_v2", null) != null ? [auth_settings_v2.value.azure_static_web_app_v2] : []
        content {
          client_id = azure_static_web_app_v2.value.client_id
        }
      }

    }
  }

  dynamic "site_config" {
    for_each = lookup(each.value, "site_config", null) != null ? [each.value.site_config] : []
    content {
      always_on                               = lookup(site_config.value, "always_on", false)
      ftps_state                              = lookup(site_config.value, "ftps_state", null)
      minimum_tls_version                     = lookup(site_config.value, "minimum_tls_version", null)
      remote_debugging_enabled                = lookup(site_config.value, "remote_debugging_enabled", null)
      remote_debugging_version                = lookup(site_config.value, "remote_debugging_version", null)
      health_check_path                       = lookup(site_config.value, "health_check_path", null)
      health_check_eviction_time_in_min       = lookup(site_config.value, "health_check_eviction_time_in_min", null)
      scm_minimum_tls_version                 = lookup(site_config.value, "scm_minimum_tls_version", null)
      websockets_enabled                      = lookup(site_config.value, "websockets_enabled", null)
      scm_use_main_ip_restriction             = lookup(site_config.value, "scm_use_main_ip_restriction", null)
      container_registry_use_managed_identity = lookup(site_config.value, "container_registry_use_managed_identity", null)
      vnet_route_all_enabled                  = lookup(site_config.value, "vnet_route_all_enabled", null)
      http2_enabled                           = lookup(site_config.value, "http2_enabled", null)
      managed_pipeline_mode                   = lookup(site_config.value, "managed_pipeline_mode", null)
      load_balancing_mode                     = lookup(site_config.value, "load_balancing_mode", null)
      auto_swap_slot_name                     = lookup(site_config.value, "auto_swap_slot_name", null)
      app_command_line                        = lookup(site_config.value, "app_command_line", null)
      api_definition_url                      = try(each.value.site_config.api_definition_url, null)
      api_management_api_id                   = try(each.value.site_config.api_management_api_id, null)

      dynamic "ip_restriction" {
        for_each = lookup(var.web_app_config.site_config, "ip_restriction", [])
        content {
          name                      = lookup(ip_restriction.value, "name", null)
          ip_address                = lookup(ip_restriction.value, "ip_address", null)
          service_tag               = lookup(ip_restriction.value, "service_tag", null)
          virtual_network_subnet_id = lookup(ip_restriction.value, "virtual_network_subnet_id", null)
          action                    = lookup(ip_restriction.value, "action", null)
          priority                  = lookup(ip_restriction.value, "priority", null)

          dynamic "headers" {
            for_each = lookup(ip_restriction.value, "headers", null) != null ? [ip_restriction.value.headers] : []
            content {
              x_forwarded_for  = lookup(headers.value, "x_forwarded_for", null)
              x_azure_fdid     = lookup(headers.value, "x_azure_fdid", null)
              x_forwarded_host = lookup(headers.value, "x_forwarded_host", null)

            }
          }
        }
      }


      dynamic "application_stack" {
        for_each = lookup(site_config.value, "application_stack", null) != null ? [site_config.value.application_stack] : []
        content {
          python_version           = lookup(application_stack.value, "python_version", null)
          node_version             = lookup(application_stack.value, "node_version", null)
          dotnet_version           = lookup(application_stack.value, "dotnet_version", null)
          java_version             = lookup(application_stack.value, "java_version", null)
          java_server              = lookup(application_stack.value, "java_server", null)
          java_server_version      = lookup(application_stack.value, "java_server_version", null)
          php_version              = lookup(application_stack.value, "php_version", null)
          ruby_version             = lookup(application_stack.value, "ruby_version", null)
          docker_image_name        = lookup(application_stack.value, "docker_image_name", null)
          docker_registry_url      = lookup(application_stack.value, "docker_registry_url", null)
          docker_registry_username = lookup(application_stack.value, "docker_registry_username", null)
        }
      }

      dynamic "scm_ip_restriction" {
        for_each = lookup(site_config.value, "scm_ip_restriction", [])
        content {
          name                      = lookup(scm_ip_restriction.value, "name", null)
          ip_address                = lookup(scm_ip_restriction.value, "ip_address", null)
          service_tag               = lookup(scm_ip_restriction.value, "service_tag", null)
          virtual_network_subnet_id = lookup(scm_ip_restriction.value, "virtual_network_subnet_id", null)
          action                    = lookup(scm_ip_restriction.value, "action", null)
          priority                  = lookup(scm_ip_restriction.value, "priority", null)

          dynamic "headers" {
            for_each = lookup(scm_ip_restriction.value, "headers", null) != null ? [scm_ip_restriction.value.headers] : []
            content {
              x_forwarded_for  = lookup(headers.value, "x_forwarded_for", null)
              x_azure_fdid     = lookup(headers.value, "x_azure_fdid", null)
              x_forwarded_host = lookup(headers.value, "x_forwarded_host", null)
            }
          }
        }
      }



    }
  }

  app_settings = lookup(each.value, "app_settings", {})

  dynamic "connection_string" {
    for_each = lookup(each.value, "connection_string", [])
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  dynamic "storage_account" {
    for_each = lookup(each.value, "storage_account", [])
    content {
      name         = storage_account.value.name
      account_name = storage_account.value.account_name
      access_key   = storage_account.value.access_key
      share_name   = storage_account.value.share_name
      type         = storage_account.value.type
      mount_path   = lookup(storage_account.value, "mount_path", null)
    }
  }

  dynamic "logs" {
    for_each = lookup(each.value, "logs", null) != null ? [each.value.logs] : []
    content {
      dynamic "application_logs" {
        for_each = lookup(logs.value, "application_logs", null) != null ? [logs.value.application_logs] : []
        content {
          file_system_level = lookup(application_logs.value, "file_system_level", null)
        }
      }
    }
  }
  dynamic "backup" {
    for_each = lookup(each.value, "backup", null) != null ? [each.value.backup] : []
    content {
      name                = backup.value.name
      storage_account_url = backup.value.storage_account_url
      enabled             = lookup(backup.value, "enabled", true)

      schedule {
        frequency_interval       = backup.value.schedule.frequency_interval
        frequency_unit           = backup.value.schedule.frequency_unit
        start_time               = lookup(backup.value.schedule, "start_time", null)
        retention_period_days    = lookup(backup.value.schedule, "retention_period_days", null)
        keep_at_least_one_backup = lookup(backup.value.schedule, "keep_at_least_one_backup", false)
      }
    }
  }




  tags = merge(var.web_app_config.tags != null ? var.web_app_config.tags : {}, lookup(each.value, "tags", {}))
  lifecycle {
    ignore_changes = [
      site_config
    ]
  }


  depends_on = [azurerm_linux_web_app.this]
}

