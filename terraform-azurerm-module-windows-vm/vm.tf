
resource "azurerm_network_interface" "main" {
  count               = var.vm_count
  name                = format("nic-${var.app}-%s-0%d", var.env, count.index + 1)
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = format("nic-${var.app}-%s-00%d", var.env, count.index + 1)
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.app == "dc" ? "Static" : "Dynamic"
    private_ip_address            = var.app == "dc" && count.index == 0 ? "${trimsuffix(var.subnet_address_prefixes[0], ".0/24")}.5" : (var.app == "dc" && count.index == 1 ? "${trimsuffix(var.subnet_address_prefixes[0], ".0/24")}.6" : null)
  }

  tags = var.tags

}

resource "azurerm_monitor_diagnostic_setting" "nic_diagnostics" {
  for_each = { for idx, nic in azurerm_network_interface.main : idx => nic.id }

  name               = format("nic-diagnostics-%s-0%d", var.env, each.key + 1)
  target_resource_id = each.value

  log_analytics_workspace_id = (
    var.location == "centralus" ? data.azurerm_log_analytics_workspace.mgmt_laworkspace.id :
    ###var.location == "eastus2" ? data.azurerm_log_analytics_workspace.dr_mgmt_laworkspace.id :
    null
  )

  metric {
    category = "AllMetrics"
  }
}


resource "azurerm_windows_virtual_machine" "main" {
  count                      = var.vm_count
  name                       = format("vm-${var.app}-%s-0%d", substr(var.env, 0, 1), count.index + 1)
  resource_group_name        = var.resource_group_name
  location                   = var.location
  size                       = var.vm_size
  zone                       = element(var.availability_zone, count.index)
  allow_extension_operations = true
  provision_vm_agent         = true
  vtpm_enabled               = false
  encryption_at_host_enabled = true
  secure_boot_enabled        = false
  timezone                   = "Central Standard Time"

  patch_assessment_mode                                  = "AutomaticByPlatform"
  patch_mode                                             = "AutomaticByPlatform"
  bypass_platform_safety_checks_on_user_schedule_enabled = true

  admin_username        = "azvmadmin"
  admin_password        = var.vm_admin_password
  network_interface_ids = [element(azurerm_network_interface.main.*.id, count.index)]

  os_disk {
    name                   = format("disk-os-${var.app}-%s-00%d", var.env, count.index + 1)
    caching                = "ReadWrite"
    storage_account_type   = var.os_disk_type
    disk_encryption_set_id = azurerm_disk_encryption_set.main.id
    disk_size_gb = var.os_disk_size
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }
  
  tags = merge(
    var.tags,
    {
      maintenance = var.env == "prod" && (count.index + 1) % 2 == 0 ? "prod_b" : (var.env == "prod" && (count.index + 1) % 2 == 1 ? "prod" : (var.env == "nonprod" && (count.index + 1) % 2 == 0 ? "nonprod_b" : (var.env == "nonprod" && (count.index + 1) % 2 == 1 ? "nonprod" : ""))),
      
      # Add new patchgroup tag based on last digit of VM name
      patchgroup = (count.index + 1) % 2 == 0 ? "prod02" : "prod01"
    }
  )

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_disk_encryption_set" "main" {
  name                      = format("des-${var.app}-%s-001", var.env)
  resource_group_name       = var.resource_group_name
  location                  = var.location
  key_vault_key_id          = var.key_vault_key_id
  auto_key_rotation_enabled = true
  encryption_type           = "EncryptionAtRestWithPlatformAndCustomerKeys"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.uai]
  }
  tags = var.tags
}

resource "azurerm_managed_disk" "data" {
  count                  = var.vm_count == 1 ? var.disk_count : var.disk_count * var.vm_count
  name                   = format("disk-${var.app}-%s-data-00%d", var.env, count.index + 1)
  location               = var.location
  create_option          = "Empty"
  disk_size_gb           = var.data_disk_size
  resource_group_name    = var.resource_group_name
  storage_account_type   = var.managed_disk_type
  zone                   = element(var.availability_zone, count.index)
  disk_encryption_set_id = azurerm_disk_encryption_set.main.id
  tags                   = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count              = var.vm_count == 1 ? var.disk_count : var.disk_count * var.vm_count
  virtual_machine_id = azurerm_windows_virtual_machine.main[count.index % length(azurerm_windows_virtual_machine.main.*.id)].id
  managed_disk_id    = element(azurerm_managed_disk.data.*.id, count.index)
  lun                = count.index
  caching            = var.app == "dc" ? "None" : "ReadWrite"

}

# This extension is needed for other extensions
resource "azurerm_virtual_machine_extension" "daa-agent" {
  count                      = var.vm_count
  name                       = "DependencyAgentWindows"
  virtual_machine_id         = element(azurerm_windows_virtual_machine.main.*.id, count.index)
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.10"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
  tags                       = var.tags
}


# Add logging and monitoring extensions
resource "azurerm_virtual_machine_extension" "monitor-agent" {
  count = var.vm_count
  #depends_on                = [azurerm_virtual_machine_extension.daa-agent]
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = element(azurerm_windows_virtual_machine.main.*.id, count.index)
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.5"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
  tags                       = var.tags
}

resource "azurerm_virtual_machine_extension" "guest_configuration" {
  count                      = var.vm_count
  name                       = "AzurePolicyforWindows"
  virtual_machine_id         = element(azurerm_windows_virtual_machine.main.*.id, count.index)
  publisher                  = "Microsoft.GuestConfiguration"
  type                       = "ConfigurationforWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = "true"
  tags                       = var.tags
}

resource "azurerm_virtual_machine_extension" "windows_pe_install" {
  count                = var.vm_count
  name                 = "PEAgentInstallWindows"
  virtual_machine_id   = element(azurerm_windows_virtual_machine.main.*.id, count.index)
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  settings = {  
    "commandToExecute" = "powershell.exe [System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}; $webClient = New-Object System.Net.WebClient; $webClient.DownloadFile('https://vm-puppet-ent-p-01.cchhs.local:8140/packages/current/install.ps1', 'install.ps1'); .\\install.ps1 -v"
    }
  tags = var.tags
  depends_on = [azurerm_virtual_machine_extension.guest_configuration]
}

resource "azurerm_monitor_data_collection_rule_association" "main" {
  count                   = var.vm_count
  name                    = format("${var.env}-dcra-%d", count.index)
  target_resource_id      = element(azurerm_windows_virtual_machine.main.*.id, count.index)
  
  data_collection_rule_id = (
    var.location == "centralus" ? data.azurerm_monitor_data_collection_rule.windows.id :
    null
  )  
  description             = "DCR for Servers"
}


resource "azurerm_maintenance_assignment_virtual_machine" "main" {
  count                        = var.vm_count
  location                     = var.location
  maintenance_configuration_id = format("${var.maintenance_configuration_id}%s", element(azurerm_windows_virtual_machine.main.*.tags.maintenance, count.index))
  virtual_machine_id           = element(azurerm_windows_virtual_machine.main.*.id, count.index)
}

resource "azurerm_maintenance_assignment_virtual_machine" "main_prod_2" {
  count                        = var.env == "prod" ? var.vm_count : 0
  location                     = var.location
  maintenance_configuration_id = format("${var.maintenance_configuration_id}%s2", element(azurerm_windows_virtual_machine.main.*.tags.maintenance, count.index))
  virtual_machine_id           = element(azurerm_windows_virtual_machine.main.*.id, count.index)
}
