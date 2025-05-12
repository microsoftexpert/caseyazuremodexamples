output "azurerm_network_interface" {
  value       = flatten(azurerm_network_interface.main.*.private_ip_addresses)
  description = "The list of private ip addresses."
}

output "virtual_machine_id" {
  value       = flatten(azurerm_linux_virtual_machine.main.*.id)
  description = "The list of virtual machine ids."
}

output "versionless_key_info" {
  value = data.azurerm_key_vault_key.linuxvm_encryption_key.versionless_id
}
