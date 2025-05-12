output "azurerm_network_interface" {
  value       = flatten(azurerm_network_interface.main.*.private_ip_addresses)
  description = "The list of private ip addresses."
}

output "virtual_machine_id" {
  value       = flatten(azurerm_windows_virtual_machine.main.*.id)
  description = "The list of virtual machine ids."
}
