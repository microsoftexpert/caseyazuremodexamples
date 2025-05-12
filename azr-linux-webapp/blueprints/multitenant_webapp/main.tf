######################################################################################################
# Azure Linux Web App Blueprint - Multitenant Web App
#
# This blueprint provisions a multitenant-ready Linux Web App designed to host multiple client tenants
# securely within a single app instance. It supports tenant context isolation via app settings or route
# logic and includes identity and TLS best practices.
#
# 🛡️ Use Cases Supported:
# - Hosting multiple customer tenants with dynamic app behavior
# - Building SaaS platforms with per-tenant app settings or connection strings
# - Apps using authentication providers to isolate tenants at runtime
#
# 🧩 Key Capabilities:
# - App settings for per-tenant configuration
# - Support for multiple connection strings and environment variables
# - TLS and identity support for secure access
# - Optional slot-based deployment or blue-green models
#
# 🌍 Real-World Scenarios:
# - A SaaS product allows 100 tenants to use a single app with dynamic routing based on hostname
# - An API service separates tenant auth contexts using OAuth and app settings
# - A CRM system serves clients with isolated data via connection strings and app config
#
# 🚀 Optional Enhancements (Commented Below):
# - Enable daily backups and diagnostic logging
# - Add staging slot with sticky settings
# - Configure Azure AD authentication per tenant
# - Use headers or path routing to determine active tenant
######################################################################################################


module "web_app" {
  source = "../../atomic"

  web_app_config = {
    name                = var.web_app_config.name
    location            = var.web_app_config.location
    resource_group_name = var.web_app_config.resource_group_name
    service_plan_id     = var.web_app_config.service_plan_id
    https_only          = true

    site_config = {
      always_on        = true
      linux_fx_version = "DOTNETCORE|7.0"

      # Optional: Health probe
      # health_check_path = "/health"
    }

    # Optional: Easy Auth for tenant ID filtering
    auth_settings_v2 = {
      auth_enabled = true
      active_directory_v2 = [{
        client_id                  = var.web_app_config.auth_settings_v2.active_directory_v2.client_id
        tenant_auth_endpoint       = var.web_app_config.auth_settings_v2.active_directory_v2.tenant_auth_endpoint
        client_secret_setting_name = var.web_app_config.auth_settings_v2.active_directory_v2.client_secret_setting_name
        jwt_allowed_groups         = var.web_app_config.auth_settings_v2.active_directory_v2.jwt_allowed_groups
      }]
    }

    # Optional: Tenant routing via custom app settings
    # app_settings = {
    #   "TENANT_SOURCE"  = "header"
    #   "ALLOW_TENANTS"  = "tenant-a,tenant-b"
    #   "BRAND_STYLE"    = "multi"
    # }

    # Optional: Restrict access by IP or x-tenant-id header
    # ip_restriction = [
    #   {
    #     name       = "TrustedTenantProxy"
    #     priority   = 100
    #     action     = "Allow"
    #     headers = {
    #       x_forwarded_for = ["203.0.113.12"]
    #     }
    #   }
    # ]

    # Optional: Diagnostic logs for auditing
    # logs = {
    #   application_logs = {
    #     file_system_level = "Information"
    #   }
    #   http_logs = {
    #     file_system = {
    #       retention_in_mb   = 100
    #       retention_in_days = 7
    #     }
    #   }
    # }

    # Optional: Zip deploy (React/Angular frontend for each tenant UI)
    # zip_deploy_file = "build.zip"

    # Optional: Backup configuration
    # backup = {
    #   name                = "multi-backup"
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
