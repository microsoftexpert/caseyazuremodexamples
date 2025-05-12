######################################################################################################
# Azure Linux Web App Blueprint - Secured Authentication Variants
#
# This blueprint demonstrates multiple authentication and security options for an Azure Linux Web App.
# It is designed to support the following **merged use cases**:
#
# 🔐 Use Case 1: Custom Authentication Web App
# - Easy Auth v1 or v2 integration (via Azure AD or other providers)
# - App-level login enforcement and token store configuration
# - Support for custom OAuth/OpenID Connect providers (Google, Facebook, Apple, etc.)
#
# 🤝 Use Case 2: B2B Certificate + CORS Web App
# - Frontend/backend separation with CORS configuration
# - Certificate thumbprint enforcement for trusted B2B clients
# - Secure integration with partner portals and external domains
#
# 🛡️ Use Case 3: Zero Trust Secure Web App
# - IP-based access restriction for Zero Trust network controls
# - Client certificate enforcement
# - Optional VNet integration for secure internal exposure
# - Strong TLS configuration, minimum TLS version enforcement
#
# 🧩 Key Features:
# - Identity: System-assigned or user-assigned managed identity
# - Authentication: Azure AD, Microsoft Identity, and optional providers (Google, Facebook, Apple)
# - CORS: Customizable CORS rules with credential support
# - Certificates: Client certificate enforcement + exclusion paths
# - IP Restrictions: Named allow/deny rules with optional forwarded header filtering
# - Networking: Optional VNet integration via `virtual_network_subnet_id`
# - Tags: Easily tag for environment, owner, or compliance labeling
#
# 🚀 Optional Enhancements (Commented Below):
# - App settings block for Application Insights or feature toggles
# - Custom Linux runtime stack configuration (`linux_fx_version`)
# - Additional authentication identity providers
# - Exclusion paths for client cert-required routes
# - Fine-grained IP header-based restriction (e.g., X-Forwarded-For)
# - Auth redirect and default provider customization
# - Virtual Network subnet integration for private access
# - Expanded tag set for tracking ownership and purpose
######################################################################################################

module "secured_webapp" {
  source = "../../atomic"

  web_app_config = {
    name                = var.web_app_config.name
    resource_group_name = var.web_app_config.resource_group_name
    location            = var.web_app_config.location
    service_plan_id     = var.web_app_config.service_plan_id

    identity = {
      type         = "SystemAssigned"
      # Uncomment and configure below to use user-assigned identity
      # type         = "UserAssigned"
      # identity_ids = [
      #   "/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.ManagedIdentity/userAssignedIdentities/my-identity"
      # ]
    }

    site_config = {
      always_on       = true
      ftps_state      = "Disabled"
      http2_enabled   = true
      min_tls_version = "1.2"

      # Uncomment to set the runtime stack
      # linux_fx_version = "PYTHON|3.9"
      # linux_fx_version = "NODE|18-lts"
      # linux_fx_version = "DOTNETCORE|6.0"

      # Uncomment to allow client certs to bypass specific paths
      # client_certificate_exclusion_paths = ["/health", "/public"]

      # Uncomment to enable app settings
      # app_settings = {
      #   "APPINSIGHTS_INSTRUMENTATIONKEY" = "xxxx"
      #   "ENVIRONMENT"                    = "Production"
      # }
    }

    auth_settings_v2 = {
      auth_enabled           = true
      require_authentication = true

      login = {
        token_store_enabled                  = true
        preserve_url_fragments_for_logins   = false
      }

      active_directory = {
        client_id             = var.web_app_config.auth_settings_v2.active_directory.client_id
        tenant_auth_endpoint = var.web_app_config.auth_settings_v2.active_directory.tenant_auth_endpoint
      }

      # Uncomment to configure external identity providers
      # google = {
      #   client_id                  = "your-google-client-id"
      #   client_secret_setting_name = "google-secret"
      # }

      # facebook = {
      #   app_id                  = "facebook-app-id"
      #   app_secret_setting_name = "fb-secret"
      # }

      # apple = {
      #   client_id                  = "apple-client-id"
      #   client_secret_setting_name = "apple-secret"
      # }

      # Optional redirect handling
      # unauthenticated_action = "RedirectToLoginPage"
      # default_provider        = "AzureActiveDirectory"
    }

    cors = {
      allowed_origins     = ["https://partner.example.com"]
      support_credentials = true
    }

    client_cert_enabled = true
    client_cert_mode    = "Required"

    ip_restriction = [
      {
        name       = "AllowCorporateOffice"
        ip_address = "203.0.113.10/32"
        action     = "Allow"
        priority   = 100

        # Uncomment to restrict by header
        # headers = {
        #   x_forwarded_for = ["203.0.113.10"]
        # }
      },
      # {
      #   name       = "DenyAllOthers"
      #   ip_address = "0.0.0.0/0"
      #   action     = "Deny"
      #   priority   = 200
      # }
    ]

    # Uncomment to enable secure VNet integration
    # virtual_network_subnet_id = "/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Network/virtualNetworks/vnet/subnets/web-subnet"

    tags = {
      environment = "secure-auth"
      owner       = "devops-team"
      compliance  = "ZeroTrust"
    }
  }
}
