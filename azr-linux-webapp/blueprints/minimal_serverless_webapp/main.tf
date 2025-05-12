########################
# Blueprint: minimal_serverless
#
# 📘 Description:
# Deploys a flexible Linux Web App that supports both **minimal** and **serverless event-driven** workloads.
# Ideal for lightweight APIs, function apps, or apps triggered by blob/queue/timer events.
#
# Use this blueprint when you want to:
# ✅ Deploy a basic web app with minimal infrastructure and cost
# ✅ Run Azure Functions with blob, timer, or queue triggers
# ✅ Quickly prototype microservices with flexible deployment
# ✅ Enable CI/CD for iterative function-based deployments
#
# 🔧 Real-World Scenarios:
# - ✅ Blob-triggered image processing
# - ✅ Scheduled functions (e.g., billing, cleanup)
# - ✅ Queue-triggered background tasks
# - ✅ Minimal APIs, dashboards, or static hosting
#
# ✅ Benefits:
# - Fully managed compute and autoscaling
# - Pay-per-use or elastic premium options
# - Optional VNet, Auth, Logging, CORS, and Key Vault bindings
#
# ⚙️ Optional Enhancements Shown:
# - Durable Functions & binding-specific app settings
# - Authentication (Easy Auth v2 with Azure AD)
# - Identity for secure access to Key Vault or Storage
# - Auto-heal config, IP Restrictions, Logging, and Backup
# - Zip deploy of packages from GitHub Actions or other CI/CD
########################

module "web_app" {
  source = "../../atomic"

  web_app_config = {
    name                = "linuxwebapp-event-api"
    location            = "East US"
    resource_group_name = "rg-serverless-demo"
    service_plan_id     = "Y1"

    https_only = true

    site_config = {
      always_on        = true
      linux_fx_version = "PYTHON|3.11"

      # use_32_bit_worker_process = false
      # websockets_enabled = true
      # remote_debugging_enabled = false
      # remote_debugging_version = "VS2022"
      # minimum_tls_version = "1.2"
      # ftps_state          = "Disabled"

      # Optional: Auto-heal triggers
      # auto_heal_enabled = true
      # auto_heal_setting = {
      #   trigger = {
      #     private_bytes_in_kb = 512000
      #   }
      #   action = {
      #     action_type = "Recycle"
      #   }
      # }
    }

    # Optional: Deploy ZIP package with function code
    # zip_deploy_file = "./functionapp.zip"

    # Optional: Function + trigger bindings
    # app_settings = {
    #   "FUNCTIONS_WORKER_RUNTIME"                = "python"
    #   "FUNCTIONS_EXTENSION_VERSION"            = "~4"
    #   "AzureWebJobsStorage"                    = "DefaultEndpointsProtocol=...;"
    #   "WEBSITE_RUN_FROM_PACKAGE"               = "1"
    #   "BlobTriggerInputContainer"              = "incoming-files"
    #   "TIMER_SCHEDULE"                         = "0 */5 * * * *"
    #   "SERVICEBUS_QUEUE"                       = "task-queue"
    # }

    # Optional: Auth for function endpoints
    # auth_settings = {
    #   enabled                        = true
    #   issuer                         = "https://sts.windows.net/${var.tenant_id}/"
    #   default_provider               = "AzureActiveDirectory"
    #   unauthenticated_client_action  = "RedirectToLoginPage"
    #   token_store_enabled            = true
    #   active_directory = {
    #     client_id                   = "00000000-0000-0000-0000-000000000000"
    #     client_secret_setting_name = "aad-client-secret"
    #     allowed_audiences          = ["api://linuxwebapp-event-api"]
    #   }
    # }

    # Optional: Managed Identity
    # identity = {
    #   type = "SystemAssigned"
    # }

    # Optional: Logging
    # logs = {
    #   application_logs = {
    #     file_system_level = "Verbose"
    #   }
    #   http_logs = {
    #     file_system = {
    #       retention_in_mb   = 100
    #       retention_in_days = 7
    #     }
    #   }
    # }

    # Optional: Restrict IPs
    # ip_restrictions = [
    #   {
    #     name       = "AllowCorp"
    #     priority   = 100
    #     ip_address = "203.0.113.1"
    #     headers = {
    #       x_forwarded_for = ["203.0.113.1"]
    #     }
    #   }
    # ]

    # Optional: Enable backup
    # backup = {
    #   name                = "daily-backup"
    #   storage_account_url = "https://mystorage.blob.core.windows.net/backups?sig=..."
    #   schedule = {
    #     frequency_interval       = 1
    #     frequency_unit           = "Day"
    #     keep_at_least_one_backup = true
    #     retention_period_in_days = 30
    #     start_time               = "2024-01-01T00:00:00Z"
    #   }
    # }

    tags = {
      environment = "dev"
      blueprint   = "merged_minimal_serverless"
    }
  }
}
