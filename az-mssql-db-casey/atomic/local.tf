locals {
  sql_primary_user_assigned_identity_id = null
  # Build the full Key Vault Key ID for Transparent Data Encryption (TDE) CMK
  tde_key_vault_key_id = try(
    var.key_vault_id != null
    ? "${var.key_vault_id}/keys/${var.mssql_config.server.name}-cmk"
    : null,
    null
  )
}
