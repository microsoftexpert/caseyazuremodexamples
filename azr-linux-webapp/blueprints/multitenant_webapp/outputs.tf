output "web_app_name" {
  description = "The name of the multi-tenant Linux Web App."
  value       = module.multitenant_webapp.web_app_name
}

output "web_app_id" {
  description = "The Azure Resource ID of the multi-tenant Linux Web App."
  value       = module.multitenant_webapp.web_app_id
}

output "web_app_identity" {
  description = "The managed identity block (system/user-assigned) of the Web App."
  value       = module.multitenant_webapp.web_app_identity
}

output "web_app_default_hostname" {
  description = "The default DNS hostname of the deployed multi-tenant Web App."
  value       = module.multitenant_webapp.web_app_default_hostname
}

output "web_app_app_settings" {
  description = "Tenant-aware application settings configured on the Web App."
  value       = module.multitenant_webapp.web_app_app_settings
}

output "web_app_connection_strings" {
  description = "Database or service connection strings, optionally scoped per tenant."
  value       = module.multitenant_webapp.web_app_connection_strings
}
