output "mssql_server_id" {
  description = "The ID of the deployed Azure MSSQL Server."
  value       = module.standard_database.mssql_server_id
}

output "mssql_server_fqdn" {
  description = "The Fully Qualified Domain Name (FQDN) of the deployed Azure MSSQL Server."
  value       = module.standard_database.mssql_server_fqdn
}

output "mssql_database_ids" {
  description = "A map of database names to their corresponding Azure MSSQL Database IDs."
  value       = module.standard_database.mssql_database_ids
}

output "mssql_database_names" {
  description = "A list of all created Azure MSSQL Database names."
  value       = module.standard_database.mssql_database_names
}

output "mssql_server_identity" {
  description = "The identity information of the Azure MSSQL Server if identity is enabled."
  value       = try(module.standard_database.mssql_server_identity, null)
}

output "mssql_database_encryption_keys" {
  description = "A map of database names to their respective Transparent Data Encryption (TDE) key IDs, if configured."
  value       = try(module.standard_database.mssql_database_encryption_keys, {})
}

output "mssql_threat_detection_policies" {
  description = "A map of database names to their respective threat detection policy states."
  value       = try(module.standard_database.mssql_threat_detection_policies, {})
}

output "mssql_extended_auditing_policies" {
  description = "A map of database names to their respective extended auditing policy storage endpoints."
  value       = try(module.standard_database.mssql_extended_auditing_policies, {})
}

output "mssql_resource_group_name" {
  description = "The name of the resource group where the MSSQL Server is deployed."
  value       = module.standard_database.mssql_resource_group_name
}
