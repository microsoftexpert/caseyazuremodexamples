output "web_app_name" {
  description = "The name of the deployed Linux Web App."
  value       = module.secured_webapp.web_app_name
}

output "web_app_id" {
  description = "The Azure Resource ID of the Linux Web App."
  value       = module.secured_webapp.web_app_id
}

output "web_app_default_hostname" {
  description = "The default publicly accessible hostname of the web app."
  value       = module.secured_webapp.web_app_default_hostname
}

output "web_app_identity" {
  description = "The system-assigned or user-assigned managed identity block for the web app."
  value       = module.secured_webapp.web_app_identity
}

output "web_app_auth_settings_v2" {
  description = "The authentication settings v2 block returned by the deployed web app."
  value       = module.secured_webapp.web_app_auth_settings_v2
}

output "web_app_client_cert_enabled" {
  description = "Whether client certificates are enabled on the app."
  value       = module.secured_webapp.web_app_client_cert_enabled
}

output "web_app_ip_restrictions" {
  description = "The list of IP restrictions applied to the app."
  value       = module.secured_webapp.web_app_ip_restriction
}

output "web_app_cors_settings" {
  description = "CORS configuration applied to the app."
  value       = module.secured_webapp.web_app_cors
}

output "web_app_virtual_network_subnet_id" {
  description = "The subnet ID used for VNet integration (if applicable)."
  value       = module.secured_webapp.web_app_virtual_network_subnet_id
}
