######################################################################################################
# Azure Linux Web App Blueprint - Enterprise Networked Web App
#
# This blueprint provides a highly secure and network-isolated deployment pattern for hosting
# enterprise-grade applications on Azure Linux Web Apps. It is designed for organizations that
# require strict perimeter control, internal-only exposure, and infrastructure that aligns with
# corporate networking and compliance policies.
#
# 🛡️ Use Cases Supported:
# - Deploying internal line-of-business (LOB) apps that must not be publicly exposed
# - Hosting enterprise APIs behind a private VNet or Application Gateway
# - Restricting web app access to only approved corporate offices or partner networks
# - Supporting hybrid cloud apps that live in a private networking topology
#
# 🧩 Key Capabilities:
# - Virtual Network Integration (regional or with App Service Environment)
# - Support for App Service Environment v3 (`app_service_environment_id`)
# - Configurable IP restrictions with named allow/deny rules
# - Optional header-based filtering using X-Forwarded-For
# - System-assigned or user-assigned managed identity
# - Secure TLS configuration (TLS 1.2 or higher, FTPS control)
# - Full support for tags, connection strings, and app settings
# - Slot-based deployment and sticky site configurations
#
# 🌍 Real-World Scenarios:
# - A healthcare provider hosts an internal patient record portal only accessible from its hospital offices
# - A financial firm deploys a compliance dashboard that must run in an App Service Environment with IP filtering
# - A large enterprise runs a legacy backend service within a private VNet, only accessible through a VPN
# - A manufacturing company integrates factory-floor APIs with private network restrictions and managed identity
#
# 🚀 Optional Enhancements (Commented Below):
# - Custom Linux runtime stack (Python, Node, .NET, or Docker)
# - Connection strings to databases or APIs (MySQL, Redis, Service Bus)
# - Diagnostic logging, backup, and monitoring integrations
# - Client certificate enforcement and path exclusions
# - App Insights instrumentation key injection via `app_settings`
# - Extended subnet-based access control with NSGs or Private Endpoints
######################################################################################################

module "enterprise_networked_webapp" {
  source = "../../atomic"

  web_app_config = {
    name                = var.web_app_config.name
    resource_group_name = var.web_app_config.resource_group_name
    location            = var.web_app_config.location
    service_plan_id     = var.web_app_config.service_plan_id

    app_service_environment_id = var.web_app_config.app_service_environment_id

    identity = {
      type = "SystemAssigned"
      # type = "UserAssigned"
      # identity_ids = [
      #   "/subscriptions/.../resourceGroups/.../providers/Microsoft.ManagedIdentity/userAssignedIdentities/identity1",
      #   "/subscriptions/.../resourceGroups/.../providers/Microsoft.ManagedIdentity/userAssignedIdentities/identity2"
      # ]
    }

    site_config = {
      always_on       = true
      ftps_state      = "Disabled"
      http2_enabled   = true
      min_tls_version = "1.2"

      # Optional runtime stack
      # linux_fx_version = "PYTHON|3.10"
      # linux_fx_version = "DOTNETCORE|6.0"
      # linux_fx_version = "NODE|18-lts"
      # linux_fx_version = "DOCKER|mcr.microsoft.com/your-image:tag"

      # Optional diagnostic + runtime settings
      # scm_type                  = "LocalGit"
      # remote_debugging_enabled = false
      # websockets_enabled       = true
      # always_on                = true
      # health_check_path        = "/health"

      # App Settings
      # app_settings = {
      #   "APPINSIGHTS_INSTRUMENTATIONKEY" = "abc123"
      #   "ENVIRONMENT"                    = "Staging"
      #   "FEATURE_X_ENABLED"              = "true"
      # }

      # Connection Strings
      # connection_strings = [
      #   {
      #     name  = "MainSQL"
      #     type  = "SQLAzure"
      #     value = "Server=tcp:sql.database.windows.net;Database=mydb;..."
      #   },
      #   {
      #     name  = "Cache"
      #     type  = "Custom"
      #     value = "redis://..."
      #   },
      #   {
      #     name  = "ServiceBus"
      #     type  = "ServiceBus"
      #     value = "Endpoint=sb://..."
      #   }
      # ]
    }

    client_cert_enabled = false
    # client_cert_mode = "Required"  # or "Optional"

    virtual_network_subnet_id = var.web_app_config.virtual_network_subnet_id

    ip_restriction = [
      {
        name       = "AllowHQ"
        ip_address = "203.0.113.25/32"
        action     = "Allow"
        priority   = 100

        # Optional forwarded headers
        # headers = {
        #   x_forwarded_for  = ["203.0.113.25"]
        #   x_forwarded_host = ["hq.corp.local"]
        # }
      },
      {
        name       = "DenyInternet"
        ip_address = "0.0.0.0/0"
        action     = "Deny"
        priority   = 200
      }
    ]

    tags = {
      environment = "Enterprise"
      department  = "IT"
      costcenter  = "INFRA123"
      owner       = "infra-ops"
    }
  }
}
