output "web_app_name" {
  description = "The name of the deployed Linux Web App."
  value       = module.enterprise_networked_webapp.web_app_name
}

output "web_app_id" {
  description = "The Azure Resource ID of the Linux Web App."
  value       = module.enterprise_networked_webapp.web_app_id
}

output "web_app_default_hostname" {
  description = "The default public hostname of the Linux Web App."
  value       = module.enterprise_networked_webapp.web_app_default_hostname
}

output "web_app_identity" {
  description = "The managed identity block (system/user-assigned) of the Web App."
  value       = module.enterprise_networked_webapp.web_app_identity
}

output "web_app_virtual_network_subnet_id" {
  description = "The subnet ID used for VNet integration, if configured."
  value       = module.enterprise_networked_webapp.web_app_virtual_network_subnet_id
}

output "web_app_ip_restriction" {
  description = "List of IP restrictions applied to the Web App."
  value       = module.enterprise_networked_webapp.web_app_ip_restriction
}

output "web_app_tags" {
  description = "Tags applied to the Linux Web App resource."
  value       = module.enterprise_networked_webapp.web_app_tags
}

output "web_app_connection_strings" {
  description = "The resolved connection strings applied to the web app (if any)."
  value       = module.enterprise_networked_webapp.web_app_connection_strings
}

output "web_app_app_settings" {
  description = "The application settings applied to the web app."
  value       = module.enterprise_networked_webapp.web_app_app_settings
}
