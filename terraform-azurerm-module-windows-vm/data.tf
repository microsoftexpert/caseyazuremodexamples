data "azurerm_log_analytics_workspace" "mgmt_laworkspace" {
  name                = "law-mgmt-shared-prod-001"
  resource_group_name = "rg-mgmt-shared-prod-001"
  #provider = azurerm.mgmt
}

# data "azurerm_log_analytics_workspace" "dr_mgmt_laworkspace" {
#   name                = "law-mgmt-shared-eu2-prod-001"
#   resource_group_name = "rg-monitor-mgmt-eu2-int-001"
#   #provider = azurerm.mgmt
# }

data "azurerm_monitor_data_collection_rule" "windows" {
  name                = "collection-windows-mgmt-vm-rules"
  resource_group_name = "rg-monitor-mgmt-int-001"
  #provider = azurerm.mgmt
}

# data "azurerm_monitor_data_collection_rule" "dr_windows" {
#   name                = "dr-collection-windows-mgmt-vm-rules"
#   resource_group_name = "rg-monitor-mgmt-eu2-int-001"
#   #provider = azurerm.mgmt
# }