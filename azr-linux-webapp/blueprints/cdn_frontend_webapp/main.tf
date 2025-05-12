########################
# Blueprint: cdn_fronted_webapp
#
# 📘 Description:
# Deploys a Linux Web App to serve frontend content (HTML/CSS/JS) globally with edge acceleration using Azure CDN.
#
# Combines:
# - ✅ Azure App Service for zip-deployed frontend (React/Vue/Angular/etc.)
# - ✅ Azure CDN for global caching of assets (HTML, CSS, JS, images, video)
# - ✅ Optional custom domain + SSL binding (manual or managed cert)
#
# 🔄 How to Use:
# - Deploy Web App with zip file from CI/CD (npm run build → build.zip)
# - CDN caches assets and passes API calls to origin Web App
# - Optionally configure custom domain with HTTPS support
#
# 🔧 Real-World Scenarios:
# - ✅ React or Angular SPA frontend hosting (with API backend)
# - ✅ Headless CMS delivery (Contentful, Sanity, etc.)
# - ✅ Portfolio sites or landing pages using GitHub Actions
# - ✅ Corporate marketing sites or multi-region frontends
# - ✅ Developer portals needing fast asset delivery
# - ✅ SaaS apps serving dashboards from a global CDN
#
# ✅ Benefits:
# - Global performance with local caching
# - Integrated TLS, logging, CORS, and domain support
# - CI/CD friendly (GitHub Actions, DevOps)
# - Zero-downtime deploys with backup and staging slot options
#
# ⚙️ Optional Enhancements (commented below):
# - Zip deploy from build pipelines
# - Diagnostic logs for traffic analysis
# - Scheduled App Service backups
# - CORS config for frontend/backend separation
# - Custom domains with managed certificates
# - Identity for secure access to APIs or Key Vault
########################

resource "azurerm_cdn_profile" "this" {
  name                = "${var.web_app_config.name}-cdn-profile"
  location            = var.web_app_config.location
  resource_group_name = var.web_app_config.resource_group_name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "this" {
  name                = "${var.web_app_config.name}-cdn-endpoint"
  profile_name        = azurerm_cdn_profile.this.name
  location            = var.web_app_config.location
  resource_group_name = var.web_app_config.resource_group_name

  origin {
    name      = "webapp-origin"
    host_name = module.web_app.web_app_default_site_hostname
  }

  is_http_allowed      = false
  is_https_allowed     = true
  origin_host_header   = module.web_app.web_app_default_site_hostname

  # Optional: Enable compression for common MIME types
  # content_types_to_compress = ["text/html", "text/css", "application/javascript", "application/json"]

  tags = var.web_app_config.tags
}

module "web_app" {
  source = "../../atomic"

  web_app_config = {
    name                = var.web_app_config.name
    location            = var.web_app_config.location
    resource_group_name = var.web_app_config.resource_group_name
    service_plan_id     = var.web_app_config.service_plan_id
    https_only          = true

    site_config = {
      always_on               = true
      minimum_tls_version     = "1.2"
      scm_minimum_tls_version = "1.2"

      # Optional: Enable CORS for backend API calls
      # cors = {
      #   allowed_origins     = ["https://frontend.example.com"]
      #   support_credentials = true
      # }

      # Optional: Enable IP restriction to only allow traffic via CDN
      # ip_restriction = [{
      #   name       = "CDNOnly"
      #   priority   = 100
      #   action     = "Allow"
      #   ip_address = "AzureFrontDoor.Backend"
      # }]
    }

    # Optional: Deploy frontend build zip (npm run build → build.zip)
    # zip_deploy_file = "./build.zip"

    # Optional: App Settings (ENV, API URLs, build hashes)
    # app_settings = {
    #   ENV         = "production"
    #   API_BASE    = "https://api.example.com"
    #   BUILD_HASH  = "v1.0.3"
    # }

    # Optional: Use identity to securely call APIs / Key Vault
    # identity = {
    #   type = "SystemAssigned"
    # }

    # Optional: Custom Domain Verification ID (for binding)
    # custom_domain_verification_id = var.web_app_config.custom_domain_verification_id

    # Optional: Logging for debugging and monitoring
    # logs = {
    #   application_logs = {
    #     file_system_level = "Verbose"
    #   }
    #   http_logs = {
    #     file_system = {
    #       retention_in_mb   = 50
    #       retention_in_days = 7
    #     }
    #   }
    # }

    # Optional: Backup for rollback or restore
    # backup = {
    #   name                = "frontend-backup"
    #   enabled             = true
    #   storage_account_url = var.web_app_config.backup.storage_account_url
    #   schedule = {
    #     frequency_interval        = 1
    #     frequency_unit            = "Day"
    #     keep_at_least_one_backup = true
    #     retention_period_in_days = 14
    #     start_time               = "2024-01-01T00:00:00Z"
    #   }
    # }

    tags = var.web_app_config.tags
  }
}
