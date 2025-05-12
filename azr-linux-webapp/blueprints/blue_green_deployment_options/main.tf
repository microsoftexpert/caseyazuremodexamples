######################################################################################################
# Azure Linux Web App Blueprint - Advanced Deployment Web App
#
# This blueprint showcases a production-grade configuration for containerized web apps on Azure using
# advanced deployment strategies. It supports Docker-based deployments, slot management, identity,
# scaling, and continuous delivery readiness — ideal for modern DevOps pipelines and enterprise use.
#
# 🛡️ Use Cases Supported:
# - Deploying containerized apps with zero-downtime updates using deployment slots
# - Supporting blue/green or canary rollout strategies in a secure environment
# - Managing staging, QA, and production environments within a single app structure
# - Automating deployments via GitHub Actions, Azure DevOps, or custom CI/CD workflows
#
# 🧩 Key Capabilities:
# - Docker container support using custom Linux images
# - Primary + slot deployment with staging-to-production swap capability
# - Optional sticky settings, always-on, and slot-level scaling
# - System-assigned or user-assigned managed identity
# - Full support for app settings and connection strings
# - Secure TLS enforcement and runtime configuration
# - Optional logging and backup integrations
#
# 🌍 Real-World Scenarios:
# - A SaaS provider deploys a Node.js backend in a staging slot, runs smoke tests, then swaps to production
# - A DevOps team uses a CI/CD pipeline to push Docker updates into a slot, then promotes it after verification
# - A microservice deployed as a container needs secure VNet integration and a backup plan with zero downtime
#
# 🚀 Optional Enhancements (Commented Below):
# - Logging integration (App Service logs, App Insights)
# - Sticky settings across slots (connection strings, app settings)
# - Custom health check paths and SCM configuration
# - Flexible Docker image tags for multi-stage CI/CD
# - Support for GitHub Actions or Azure DevOps integration
######################################################################################################

module "advanced_deployment_webapp" {
  source = "../../atomic"

  web_app_config = {
    name                = var.web_app_config.name
    resource_group_name = var.web_app_config.resource_group_name
    location            = var.web_app_config.location
    service_plan_id     = var.web_app_config.service_plan_id

    identity = {
      type         = "SystemAssigned"
      # type         = "UserAssigned"
      # identity_ids = [
      #   "/subscriptions/.../resourceGroups/.../providers/Microsoft.ManagedIdentity/userAssignedIdentities/identity-1"
      # ]
    }

    site_config = {
      linux_fx_version         = "DOCKER|mcr.microsoft.com/appimage:latest"
      always_on                = true
      http2_enabled            = true
      min_tls_version          = "1.2"
      health_check_path        = "/health"

      # Optional diagnostics
      # scm_type                 = "LocalGit"
      # remote_debugging_enabled = false
      # websockets_enabled       = true
      # scm_minimum_tls_version  = "1.2"

      # App Settings
      # app_settings = {
      #   "APPINSIGHTS_INSTRUMENTATIONKEY" = "abc123"
      #   "DOCKER_REGISTRY_SERVER_URL"     = "https://index.docker.io"
      #   "DOCKER_REGISTRY_SERVER_USERNAME" = "mydockeruser"
      #   "DOCKER_REGISTRY_SERVER_PASSWORD" = "supersecret"
      # }

      # Connection Strings
      # connection_strings = [
      #   {
      #     name  = "MainDB"
      #     type  = "SQLAzure"
      #     value = "Server=tcp:sql.database.windows.net;Database=mydb;..."
      #   }
      # ]
    }

    slots = {
      staging = {
        site_config = {
          linux_fx_version  = "DOCKER|mcr.microsoft.com/appimage:staging"
          always_on         = true
          min_tls_version   = "1.2"
          health_check_path = "/health"

          # Optional: slot-specific settings
          # app_settings = {
          #   "ENVIRONMENT" = "staging"
          # }

          # connection_strings = [
          #   {
          #     name  = "SlotDB"
          #     type  = "SQLAzure"
          #     value = "Server=tcp:sql.database.windows.net;Database=stagingdb;..."
          #   }
          # ]
        }

        sticky_settings = {
          app_setting_names       = ["ENVIRONMENT", "DOCKER_IMAGE"]
          connection_string_names = ["SlotDB"]
        }
      }
    }

    zip_deploy_file = null  # Not used for container apps

    tags = {
      environment = "staging"
      project     = "container-deploy"
      owner       = "devops"
    }
  }
}
