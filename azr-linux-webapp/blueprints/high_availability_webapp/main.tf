######################################################################################################
# Azure Linux Web App Blueprint - High Availability Web App
#
# This blueprint provisions a resilient Linux Web App across multiple zones or regions for high
# availability (HA). It's ideal for critical production applications that require reliability,
# fault tolerance, and fast recovery across failure domains.
#
# 🛡️ Use Cases Supported:
# - Deploying production apps with availability SLA requirements
# - Resilient backend APIs or microservices hosted in Azure App Service
# - Enterprise apps that must be resilient to zone or region outages
# - Web workloads fronted by Azure Front Door or Application Gateway
#
# 🧩 Key Capabilities:
# - App Service Plan with zone redundancy or regional failover
# - System or user-assigned managed identity
# - TLS version enforcement and always-on runtime
# - Support for CORS, backup, and diagnostic logs
# - Optional sticky settings, VNet integration, and slot deployment
#
# 🌍 Real-World Scenarios:
# - A banking portal ensures resilience by enabling zone redundancy
# - A government service platform backs up app configuration and data daily
# - An API service runs in zone-redundant infrastructure and scales automatically
#
# 🚀 Optional Enhancements (Commented Below):
# - Enable daily App Service backups to blob storage
# - Configure diagnostic logs to App Insights or filesystem
# - Add deployment slots and enable blue-green strategies
# - Setup system-assigned identity for secure service access
# - Use minimum TLS version and disable FTPS for security
######################################################################################################


module "web_app" {
  source = "../../atomic"

  web_app_config = {
    name                = var.web_app_config.name
    location            = var.web_app_config.location
    resource_group_name = var.web_app_config.resource_group_name
    service_plan        = var.web_app_config.service_plan

    https_only = true

    identity = {
      type = "SystemAssigned"
    }

    site_config = {
      always_on               = true
      linux_fx_version        = "DOTNETCORE|7.0"
      number_of_workers       = 3
      health_check_path       = "/health"
      minimum_tls_version     = "1.2"
      scm_minimum_tls_version = "1.2"
      auto_heal_enabled       = true

      # Optional auto-heal trigger
      auto_heal_setting = {
        triggers = {
          slow_request = {
            count      = 10
            time_taken = "00:00:10"
            path       = "/api/ping"
          }
        }
        actions = {
          action_type             = "Recycle"
          minimum_process_execution_time = "00:01:00"
        }
      }
    }

    # Optional: Zip deploy
    # zip_deploy_file = "builds/api.zip"

    # Optional: Diagnostic logs & App Insights
    logs = {
      application_logs = {
        file_system_level = "Information"
      }
      http_logs = {
        file_system = {
          retention_in_mb   = 100
          retention_in_days = 7
        }
      }
      application_insights_key = var.web_app_config.logs.application_insights_key
    }

    # Optional: Enable authentication
    # auth_settings = {
    #   enabled                        = true
    #   issuer                         = "https://sts.windows.net/${var.tenant_id}/"
    #   default_provider               = "AzureActiveDirectory"
    #   unauthenticated_client_action  = "RedirectToLoginPage"
    #   token_store_enabled            = true
    #   active_directory = {
    #     client_id                   = var.web_app_config.auth_settings.active_directory.client_id
    #     client_secret_setting_name = var.web_app_config.auth_settings.active_directory.client_secret_setting_name
    #     allowed_audiences          = ["api://prod-ha"]
    #   }
    # }

    # Optional: IP restriction
    # ip_restriction = [
    #   {
    #     name       = "Corp"
    #     priority   = 100
    #     action     = "Allow"
    #     ip_address = "10.1.0.0/16"
    #   }
    # ]

    # Optional: VNet integration
    # virtual_network_subnet_id = var.web_app_config.virtual_network_subnet_id

    # Optional: Backup
    # backup = {
    #   name                = "prod-ha-backup"
    #   enabled             = true
    #   storage_account_url = var.web_app_config.backup.storage_account_url
    #   schedule = {
    #     frequency_interval        = 1
    #     frequency_unit            = "Day"
    #     keep_at_least_one_backup = true
    #     retention_period_in_days = 30
    #     start_time               = "2024-01-01T00:00:00Z"
    #   }
    # }

    tags = var.web_app_config.tags
  }
}
