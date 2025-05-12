output "web_app_name" {
  description = "The name of the serverless Web App."
  value       = module.web_app.web_app_name
}

output "web_app_url" {
  description = "The public URL of the Function-based Web App."
  value       = module.web_app.web_app_default_site_url
}

output "function_runtime" {
  description = "The runtime configured for Azure Functions."
  value       = try(var.web_app_config.app_settings["FUNCTIONS_WORKER_RUNTIME"], "dotnet")
}
