data "azurerm_key_vault" "key_vault_prod" {
    name = "kv-cch-mgmt-${var.env}-001"
    resource_group_name = "rg-mgmt-shared-${var.env}-001"
}

data "azurerm_key_vault" "selected_key_vault" {
  name                = var.location == "centralus" ? data.azurerm_key_vault.key_vault_prod.name : data.azurerm_key_vault.key_vault_prod.name #data.azurerm_key_vault.key_vault_dr.name
  resource_group_name = var.location == "centralus" ? data.azurerm_key_vault.key_vault_prod.resource_group_name : data.azurerm_key_vault.key_vault_prod.resource_group_name #data.azurerm_key_vault.key_vault_dr.resource_group_name
}

data "azurerm_key_vault_key" "linuxvm_encryption_key" {
  name         = format("vmkey-${var.app}-%s-001", var.env)
  key_vault_id = data.azurerm_key_vault.selected_key_vault.id
  depends_on = [ azurerm_key_vault_key.linuxvm_encryption_key, ]
}

data "azurerm_storage_account" "proddiag01" {
    name = "stcchmgmtproddiag01"
    resource_group_name = "rg-mgmt-storage-${var.env}-001"
}

data "azurerm_storage_account" "selected_storage_account" {
  name                = var.location == "centralus" ? data.azurerm_storage_account.proddiag01.name : data.azurerm_storage_account.proddiag01.name #data.azurerm_storage_account.proddiag02.name
  resource_group_name = var.location == "centralus" ? data.azurerm_storage_account.proddiag01.resource_group_name : data.azurerm_storage_account.proddiag01.resource_group_name #data.azurerm_storage_account.proddiag02.resource_group_name
}

data "azurerm_log_analytics_workspace" "mgmt_laworkspace" {
  name                = "law-mgmt-shared-prod-001"
  resource_group_name = "rg-mgmt-shared-prod-001"
}

data "azurerm_log_analytics_workspace" "dr_mgmt_laworkspace" {
  name                = "law-mgmt-shared-prod-001"
  resource_group_name = "rg-mgmt-shared-prod-001"
}



data "azurerm_monitor_data_collection_rule" "linux" {
  name                = "collection-linux-mgmt-vm-rules"
  resource_group_name = "rg-monitor-mgmt-int-001"
}

