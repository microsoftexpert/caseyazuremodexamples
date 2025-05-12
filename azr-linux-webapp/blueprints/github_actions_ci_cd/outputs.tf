output "web_app_name" {
  description = "The name of the Web App deployed for GitHub Actions CI/CD."
  value       = module.web_app.web_app_name
}

output "web_app_url" {
  description = "The publicly accessible HTTPS URL of the Web App."
  value       = module.web_app.web_app_default_site_url
}

output "web_app_identity" {
  description = "The managed identity info, useful for GitHub workflows to access Azure securely."
  value       = module.web_app.web_app_identity
}

output "web_app_identity" {
  description = "The managed identity (system or user-assigned) for the Web App."
  value       = module.github_actions_ci_cd.web_app_identity
}

output "web_app_app_settings" {
  description = "The app settings configured via GitHub Actions or Terraform."
  value       = module.github_actions_ci_cd.web_app_app_settings
}

output "web_app_default_hostname" {
  description = "The default hostname assigned to the Web App."
  value       = module.github_actions_ci_cd.web_app_default_hostname
}

output "web_app_identity" {
  description = "Managed identity of the high availability Web App."
  value       = module.high_availability_webapp.web_app_identity
}

output "web_app_app_settings" {
  description = "App settings configured on the Web App."
  value       = module.high_availability_webapp.web_app_app_settings
}

output "web_app_default_hostname" {
  description = "The default DNS name of the high availability Web App."
  value       = module.high_availability_webapp.web_app_default_hostname
}


