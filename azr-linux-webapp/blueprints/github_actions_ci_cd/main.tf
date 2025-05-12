########################
# Blueprint: github_actions_ci_cd_webapp
# Description:
# Deploys a Linux Web App integrated with a GitHub Actions CI/CD workflow.
# This blueprint shows the Terraform side of provisioning the web app,
# while GitHub Actions handles automated build and deployment.
#
# Use this blueprint when you need:
# ✅ End-to-end GitHub-based automation for app deployment
# ✅ A fast feedback loop for frontend/backend updates
# ✅ Standardized infra-as-code + GitOps approach
# ✅ Simple ZIP or container deploy from GitHub
#
# Real-World Scenarios:
# - ✅ Frontend or backend developers pushing to `main` auto-trigger deployments
# - ✅ CI builds and deploys React app or Node API with infrastructure pre-provisioned
# - ✅ Startup teams using GitHub-only workflow to ship fast
# - ✅ DevOps teams implementing GitHub PR triggers and environment approvals
#
# Optional Enhancements:
# - Enable managed identity to securely access Azure services
# - Enable logging and app settings for better diagnostics
# - Use staging slots for zero-downtime deploys
# - Add CORS, IP restrictions, or Easy Auth if needed
# - Configure GitHub Secrets to inject zip deploy or container settings
# - Add backup schedules in production workflows
########################

module "web_app" {
  source = "../../atomic"

  web_app_config = {
    name                = var.web_app_config.name
    location            = var.web_app_config.location
    resource_group_name = var.web_app_config.resource_group_name
    service_plan_id     = var.web_app_config.service_plan_id
    https_only          = true

    site_config = {
      always_on = true
    }

    # Optional: Identity for GitHub Actions to authenticate to Azure securely
    # identity = {
    #   type = "SystemAssigned"
    # }

    # Optional: Configure app settings required by your app
    # app_settings = {
    #   ENV     = "production"
    #   API_KEY = "@Microsoft.KeyVault(SecretUri=...)"
    # }

    # Optional: Log settings for debugging and diagnostics
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

    # Optional: Zip deploy will be handled by GitHub Action after build
    # Do not include zip_deploy_file here unless manually triggered

    # Optional: Add backup config to protect from failed deployments
    # backup = {
    #   name                = "github-cicd-backup"
    #   enabled             = true
    #   storage_account_url = var.web_app_config.backup.storage_account_url
    #   schedule = {
    #     frequency_interval       = 1
    #     frequency_unit           = "Day"
    #     retention_period_days    = 7
    #     keep_at_least_one_backup = true
    #   }
    # }

    tags = var.web_app_config.tags
  }
}