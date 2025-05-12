output "web_app_name" {
  description = "The name of the Web App."
  value       = module.web_app.web_app_name
}

output "web_app_url" {
  description = "The public HTTPS URL of the Web App."
  value       = module.web_app.web_app_default_site_url
}

output "web_app_hostname" {
  description = "The default hostname of the Web App (used by CDN)."
  value       = module.web_app.web_app_default_site_hostname
}

output "web_app_identity" {
  description = "The managed identity block for the Web App (if enabled)."
  value       = module.web_app.web_app_identity
}

output "cdn_profile_name" {
  description = "The name of the Azure CDN profile created."
  value       = azurerm_cdn_profile.this.name
}

output "cdn_endpoint_hostname" {
  description = "The hostname of the CDN endpoint (used by clients)."
  value       = azurerm_cdn_endpoint.this.host_name
}

output "cdn_origin_host" {
  description = "The origin hostname used by the CDN (the web app's default hostname)."
  value       = module.web_app.web_app_default_site_hostname
}

output "custom_domain_verification_id" {
  description = "The domain verification ID used for DNS TXT validation if using a custom domain."
  value       = try(var.web_app_config.custom_domain_verification_id, null)
}

output "web_app_identity" {
  description = "The managed identity block (system/user-assigned) of the Web App."
  value       = module.cdn_fronted_webapp.web_app_identity
}

output "web_app_app_settings" {
  description = "Application settings applied to the backend Web App."
  value       = module.cdn_fronted_webapp.web_app_app_settings
}

output "web_app_default_hostname" {
  description = "Default public hostname of the backend Linux Web App."
  value       = module.cdn_fronted_webapp.web_app_default_hostname
}

