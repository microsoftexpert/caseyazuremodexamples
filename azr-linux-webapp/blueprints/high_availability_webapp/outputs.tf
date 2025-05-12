output "web_app_name" {
  description = "Name of the high-availability Web App."
  value       = module.web_app.web_app_name
}

output "web_app_url" {
  description = "Public HTTPS endpoint of the Web App."
  value       = module.web_app.web_app_default_site_url
}

output "web_app_identity" {
  description = "System-assigned managed identity (if enabled)."
  value       = module.web_app.web_app_identity
}

output "web_app_health_check" {
  description = "Path used for App Service health probe."
  value       = var.web_app_config.site_config.health_check_path
}

output "application_insights_key" {
  description = "Instrumentation key used for Application Insights logging."
  value       = var.web_app_config.logs.application_insights_key
}
