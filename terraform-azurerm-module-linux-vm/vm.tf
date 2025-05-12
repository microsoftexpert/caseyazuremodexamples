resource "random_password" "linux_password" {
  count    = var.vm_count
  length      = 15
  special     = true
  min_upper   = 4
  min_lower   = 3
  min_special = 2
  min_numeric = 4
}

resource "tls_private_key" "linux-ssh-key" {
  count  = var.vm_count
  algorithm = "RSA"
  rsa_bits  = 4096
  provider = tls
}

resource "azurerm_network_interface" "main" {
  count               = var.vm_count
  name                = format("nic-${var.app}-%s-%02d", var.env, count.index + 1)
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = format("nic-${var.app}-%s-config-%02d", var.env, count.index + 1)
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.app == "dc" ? "Static" : "Dynamic"
    private_ip_address            = var.app == "dc" && count.index == 0 ? "${trimsuffix(var.subnet_address_prefixes[0], ".0/24")}.5" : (var.app == "dc" && count.index == 1 ? "${trimsuffix(var.subnet_address_prefixes[0], ".0/24")}.6" : null)
  }

  tags = var.tags

}

resource "azurerm_monitor_diagnostic_setting" "nic_diagnostics" {
  for_each = { for idx, nic in azurerm_network_interface.main : idx => nic.id }

  name               = format("nic-${var.app}-%s-diagnostics-0%d", var.env, each.key + 1)
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

resource "azurerm_linux_virtual_machine" "main" {
  count                      = var.vm_count
  name                       = format("vm-${var.app}-%s-0%d", substr(var.env, 0, 1), count.index + 1)
  resource_group_name        = var.resource_group_name
  location                   = var.location
  size                       = var.vm_size
  zone                       = element(var.availability_zone, count.index)
  license_type               = var.linux_vm_license_type
  disable_password_authentication = var.disable_password_auth
  allow_extension_operations = true
  provision_vm_agent         = true
  encryption_at_host_enabled = true
  secure_boot_enabled        = false
  patch_assessment_mode      = "AutomaticByPlatform"
  patch_mode                 = "AutomaticByPlatform"
  bypass_platform_safety_checks_on_user_schedule_enabled = true

  admin_username            = var.admin_username
  admin_password            = random_password.linux_password[count.index].result
  network_interface_ids     = [element(azurerm_network_interface.main.*.id, count.index)]
  
  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.linux-ssh-key[count.index].public_key_openssh
  }

    source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  os_disk {
    name                   = format("%s-os-disk-%s-%02d", var.env, var.app, count.index + 1)
    caching                = "ReadWrite"
    storage_account_type   = var.os_disk_type
    disk_encryption_set_id = azurerm_disk_encryption_set.main.id
    disk_size_gb           = var.os_disk_size
  }

  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.selected_storage_account.primary_blob_endpoint
  }

#   custom_data = base64encode(
#   <<-EOT
#     #!/bin/bash
#     LOG_FILE="/var/log/puppet_install.log"
#     echo "Starting Puppet agent installation check..." >> {{LOG_FILE}}
    
#     # Check if Puppet is already installed
#     if ! command -v puppet &> /dev/null
#     then
#       echo "Puppet not found, installing..." >> {{LOG_FILE}}
#       # Install Puppet agent
#       curl -k https://10.230.195.4:8140/packages/current/install.bash | sudo bash >> {{LOG_FILE}} 2>&1
#       if [ $? -eq 0 ]; then
#         echo "Puppet installation completed successfully." >> {{LOG_FILE}}
#       else
#         echo "Puppet installation failed." >> {{LOG_FILE}}
#       fi
#     else
#       echo "Puppet agent is already installed." >> {{LOG_FILE}}
#     fi
#   EOT
# )


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

  lifecycle {
    ignore_changes = [disable_password_authentication, custom_data]
  }

  depends_on = [
    time_sleep.wait_20_seconds,
  ]
}

resource "azurerm_role_assignment" "kv_access_for_virtual_machines" {
  count               = var.vm_count
  scope               = data.azurerm_key_vault.selected_key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id        = azurerm_linux_virtual_machine.main[count.index].identity[0].principal_id
}

resource "azurerm_key_vault_secret" "linux-ssh-private-key" {
  for_each = { for i in range(var.vm_count) : i => tls_private_key.linux-ssh-key[i] }

  name         = format("vm-%s-${var.admin_username}-privKey", format("${var.app}-%s-0%d", substr(var.env, 0, 1), each.key + 1))
  value        = each.value.private_key_pem
  key_vault_id = data.azurerm_key_vault.selected_key_vault.id
  expiration_date = timeadd(timestamp(), "26280h")
   lifecycle {
    ignore_changes = [ expiration_date, ]
  }
}

resource "azurerm_key_vault_secret" "linux-ssh-public-key" {
  for_each = { for i in range(var.vm_count) : i => tls_private_key.linux-ssh-key[i] }

  name         = format("vm-%s-${var.admin_username}-pubKey", format("${var.app}-%s-0%d", substr(var.env, 0, 1), each.key + 1))
  value        = each.value.public_key_openssh
  key_vault_id = data.azurerm_key_vault.selected_key_vault.id
  expiration_date = timeadd(timestamp(), "26280h")
   lifecycle {
    ignore_changes = [ expiration_date, ]
  }
}

resource "azurerm_key_vault_secret" "linux_password" {
  for_each = { for i in range(var.vm_count) : i => random_password.linux_password[i].result }
  
  name         = format("vm-%s-${var.admin_username}-pwd", format("${var.app}-%s-0%d", substr(var.env, 0, 1), each.key + 1))
  value        = each.value
  key_vault_id = data.azurerm_key_vault.selected_key_vault.id
  expiration_date = timeadd(timestamp(), "26280h")
  lifecycle {
    ignore_changes = [ expiration_date, ]
  }
}

resource "azurerm_key_vault_key" "linuxvm_encryption_key" {
  name         = format("vmkey-${var.app}-%s-001", var.env)
  key_vault_id = data.azurerm_key_vault.selected_key_vault.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts = [
    "encrypt",
    "decrypt",
    "wrapKey",
    "unwrapKey",
    "verify",
    "sign"
  ]
  expiration_date = timeadd(timestamp(), "26280h")
  rotation_policy {
    automatic {
      time_before_expiry = "P170D"
    }

    expire_after         = "P181D"
    notify_before_expiry = "P150D"
  }
  lifecycle {
    ignore_changes = [ expiration_date, ]
  }
}

resource "azurerm_disk_encryption_set" "main" {
  name                      = format("des-${var.app}-%s-001", var.env)
  resource_group_name       = var.resource_group_name
  location                  = var.location
  key_vault_key_id    = azurerm_key_vault_key.linuxvm_encryption_key.versionless_id
  auto_key_rotation_enabled = true
  encryption_type           = "EncryptionAtRestWithPlatformAndCustomerKeys"
    identity {
    type = "SystemAssigned"
  }
  tags = var.tags
  depends_on = [ azurerm_key_vault_key.linuxvm_encryption_key, ]
}

resource "azurerm_role_assignment" "key_vault_crypto_officer_access" {
  principal_id   = azurerm_disk_encryption_set.main.identity[0].principal_id
  role_definition_name = "Key Vault Crypto Officer"
  scope          = data.azurerm_key_vault.selected_key_vault.id
}

resource "azurerm_role_assignment" "key_vault_crypto_user_access" {
  principal_id   = azurerm_disk_encryption_set.main.identity[0].principal_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  scope          = data.azurerm_key_vault.selected_key_vault.id
}

resource "time_sleep" "wait_20_seconds" {
  provider = time
  depends_on = [
    azurerm_role_assignment.key_vault_crypto_officer_access,
    azurerm_role_assignment.key_vault_crypto_user_access,
    azurerm_key_vault_key.linuxvm_encryption_key,
  ]

  create_duration = "20s"
}

resource "azurerm_managed_disk" "data" {
  count = var.create_data_disks ? (var.vm_count == 1 ? length(var.data_disk_sizes) : length(var.data_disk_sizes) * var.vm_count) : 0
  name  = format("%s-data-disk-%s-%s-%02d", var.env, var.app, var.app, count.index + 1)
  location               = var.location
  create_option          = "Empty"
  disk_size_gb           = var.data_disk_sizes[count.index % length(var.data_disk_sizes)].size
  resource_group_name    = var.resource_group_name
  storage_account_type   = var.managed_disk_type
  disk_encryption_set_id = azurerm_disk_encryption_set.main.id
  tags                   = var.tags
  zone = azurerm_linux_virtual_machine.main[floor(count.index / length(var.data_disk_sizes))].zone
  depends_on = [
    time_sleep.wait_20_seconds,
  ]
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count = var.create_data_disks ? (var.vm_count == 1 ? length(var.data_disk_sizes) : length(var.data_disk_sizes) * var.vm_count) : 0

  virtual_machine_id = azurerm_linux_virtual_machine.main[floor(count.index / length(var.data_disk_sizes))].id
  managed_disk_id    = element(azurerm_managed_disk.data.*.id, count.index)
  lun                = count.index % length(var.data_disk_sizes)
  caching            = var.app == "dc" ? "None" : "ReadWrite"
}

resource "time_sleep" "wait_45_seconds_disk_attachment" {
  provider = time
  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.data,
  ]
  create_duration = "45s"
}

resource "azurerm_virtual_machine_extension" "puppet_agent" {
  count = var.vm_count
  name                    = "PuppetAgent-${var.app}-${count.index}"
  virtual_machine_id      = element(azurerm_linux_virtual_machine.main.*.id, count.index)
  publisher               = "Microsoft.Azure.Extensions"
  type                    = "CustomScript"
  type_handler_version    = "2.0"

  settings = <<SETTINGS
  {
      "commandToExecute": "curl -k https://10.230.195.4:8140/packages/current/install.bash | sudo bash"
  }
  SETTINGS
}
  # protected_settings = <<PROTECTED_SETTINGS
  #   {
  #   "commandToExecute": "chmod +x setup_disks.sh && ./setup_disks.sh",
  #   "storageAccountName": "${var.storage_account_name}",
  #   "storageAccountKey": "${var.storage_account_key}"
    
  #   }
#PROTECTED_SETTINGS
  # depends_on = [
  #   time_sleep.wait_45_seconds_disk_attachment,
  # ]


# resource "time_sleep" "wait_45_seconds_after_partition_changes" {
#   provider = time
#   depends_on = [
#     azurerm_virtual_machine_extension.disk_partitions_setup,
#   ]
#   create_duration = "45s"
# }

resource "azurerm_virtual_machine_extension" "daa-agent" {
  count                      = var.vm_count
  name                       = "DependencyAgentLinux"
  virtual_machine_id         = element(azurerm_linux_virtual_machine.main.*.id, count.index)
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentLinux"
  type_handler_version       = "9.10"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
  tags                       = var.tags
  depends_on = [ time_sleep.wait_45_seconds_disk_attachment, ]
  # depends_on = [ time_sleep.wait_45_seconds_after_partition_changes, ]
}

resource "azurerm_virtual_machine_extension" "monitor-agent" {
  count = var.vm_count
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = element(azurerm_linux_virtual_machine.main.*.id, count.index)
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.5"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
  tags                       = var.tags
  depends_on = [ time_sleep.wait_45_seconds_disk_attachment, ]
  #depends_on = [ time_sleep.wait_45_seconds_after_partition_changes, ]
}

resource "azurerm_virtual_machine_extension" "guest_configuration" {
  count                      = var.vm_count
  name                       = "AzurePolicyforLinux"
  virtual_machine_id         = element(azurerm_linux_virtual_machine.main.*.id, count.index)
  publisher                  = "Microsoft.GuestConfiguration"
  type                       = "ConfigurationforLinux"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = "true"
  tags                       = var.tags
  #depends_on = [ time_sleep.wait_45_seconds_after_partition_changes, ]
  depends_on = [ time_sleep.wait_45_seconds_disk_attachment, ]
  lifecycle {
    ignore_changes = [ type_handler_version, ]
  }
}

resource "azurerm_monitor_data_collection_rule_association" "main" {
  count                   = var.vm_count
  name                    = format("${var.env}-dcra-%d", count.index)
  target_resource_id      = element(azurerm_linux_virtual_machine.main.*.id, count.index)
  
  data_collection_rule_id = (
    var.location == "centralus" ? data.azurerm_monitor_data_collection_rule.linux.id :
    ###var.location == "eastus2" ? data.azurerm_monitor_data_collection_rule.dr_linux.id :
    null
  )  
  description             = "DCR for Servers"
}

resource "azurerm_maintenance_assignment_virtual_machine" "main" {
  count                        = var.vm_count
  location                     = var.location
  maintenance_configuration_id = format("${var.maintenance_configuration_id}%s", element(azurerm_linux_virtual_machine.main.*.tags.maintenance, count.index))
  virtual_machine_id           = element(azurerm_linux_virtual_machine.main.*.id, count.index)
}

resource "azurerm_maintenance_assignment_virtual_machine" "main_prod_2" {
  count                        = var.env == "prod" ? var.vm_count : 0
  location                     = var.location
  maintenance_configuration_id = format("${var.maintenance_configuration_id}%s2", element(azurerm_linux_virtual_machine.main.*.tags.maintenance, count.index))
  virtual_machine_id           = element(azurerm_linux_virtual_machine.main.*.id, count.index)
}
