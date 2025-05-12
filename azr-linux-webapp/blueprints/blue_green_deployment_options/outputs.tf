output "web_app_name" {
  description = "The name of the deployed Linux Web App."
  value       = module.advanced_deployment_webapp.web_app_name
}

output "web_app_id" {
  description = "The Azure Resource ID of the Linux Web App."
  value       = module.advanced_deployment_webapp.web_app_id
}

output "web_app_default_hostname" {
  description = "The default public hostname of the Linux Web App."
  value       = module.advanced_deployment_webapp.web_app_default_hostname
}

output "web_app_identity" {
  description = "The managed identity block (system/user-assigned) of the Web App."
  value       = module.advanced_deployment_webapp.web_app_identity
}

output "web_app_tags" {
  description = "Tags applied to the Linux Web App resource."
  value       = module.advanced_deployment_webapp.web_app_tags
}

output "web_app_connection_strings" {
  description = "The resolved connection strings for the main app."
  value       = module.advanced_deployment_webapp.web_app_connection_strings
}

output "web_app_app_settings" {
  description = "Application settings applied to the main app."
  value       = module.advanced_deployment_webapp.web_app_app_settings
}

output "web_app_slot_names" {
  description = "List of slot names configured for this web app."
  value       = keys(try(module.advanced_deployment_webapp.web_app_slots, {}))
}

output "web_app_slot_hostnames" {
  description = "Map of slot names to their default hostnames."
  value       = try(module.advanced_deployment_webapp.web_app_slot_hostnames, {})
}

output "web_app_slot_app_settings" {
  description = "Map of slot names to their resolved app settings."
  value       = try(module.advanced_deployment_webapp.web_app_slot_app_settings, {})
}

output "web_app_slot_connection_strings" {
  description = "Map of slot names to their resolved connection strings."
  value       = try(module.advanced_deployment_webapp.web_app_slot_connection_strings, {})
}

output "web_app_slot_identities" {
  description = "Map of slot names to their identity blocks, if configured."
  value       = try(module.advanced_deployment_webapp.web_app_slot_identities, {})
}
