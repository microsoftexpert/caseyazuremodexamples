output "mssql_server_id" {
  description = "The ID of the deployed Azure MSSQL Server."
  value       = azurerm_mssql_server.primary.id
}

output "mssql_server_fqdn" {
  description = "The Fully Qualified Domain Name (FQDN) of the deployed Azure MSSQL Server."
  value       = azurerm_mssql_server.primary.fully_qualified_domain_name
}

output "mssql_database_ids" {
  description = "A map of database names to their corresponding Azure MSSQL Database IDs."
  value       = { for db_name, db in azurerm_mssql_database.this : db_name => db.id }
}

output "mssql_database_names" {
  description = "A list of all created Azure MSSQL Database names."
  value       = [for db in azurerm_mssql_database.this : db.name]
}

output "mssql_server_identity" {
  description = "The identity information of the Azure MSSQL Server if identity is enabled."
  value       = try(azurerm_mssql_server.primary.identity, null)
}

output "mssql_database_encryption_keys" {
  description = "A map of database names to their respective Transparent Data Encryption (TDE) key IDs, if configured."
  value       = { for db_name, db in azurerm_mssql_database.this : db_name => try(db.transparent_data_encryption_key_vault_key_id, null) if db.transparent_data_encryption_key_vault_key_id != null }
}

output "mssql_threat_detection_policies" {
  description = "A map of database names to their respective threat detection policy states."
  value       = { for db_name, db in azurerm_mssql_database.this : db_name => lookup(try(db.threat_detection_policy[0], {}), "state", null) }
}

output "mssql_extended_auditing_policies" {
  description = "A map of database names to their respective extended auditing policy storage endpoints."
  value       = { for db_name, db in azurerm_mssql_database_extended_auditing_policy.this : db_name => lookup(try(db, {}), "storage_endpoint", null) }
}

output "mssql_resource_group_name" {
  description = "The name of the resource group where the MSSQL Server is deployed."
  value       = azurerm_mssql_server.primary.resource_group_name
}
