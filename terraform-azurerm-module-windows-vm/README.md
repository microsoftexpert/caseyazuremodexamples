# module-infra-tf-azure-windows-vm
Terraform module repository for windows virtual machines in azure.

## by Casey Wood microsoftexpert@gmail.com

Here is an example:

```
module "web" {
  source                  = "app.terraform.io/<CaseyRemovedOrgForThisExample>/module-windows-vm/azurerm"
  version                 = "0.1.20"
  disk_count              = var.disk_count
  env                     = var.env
  app                     = "test"
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
  vm_count                = var.vm_count
  vm_size                 = var.vm_size
  subnet_id               = azurerm_subnet.main["snet-test-${var.env}-001"].id
  subnet_address_prefixes = azurerm_subnet.main["snet-test-${var.env}-001"].address_prefixes
  data_disk_size          = var.data_disk_size
  os_disk_type            = var.os_disk_type
  managed_disk_type       = var.managed_disk_type
  vm_admin_password       = var.vm_admin_password
  law_id                  = "/subscriptions/<CaseyRemovedIDForThisExample>/resourceGroups/rg-mgmt-shared-prod-001/providers/Microsoft.OperationalInsights/workspaces/law-mgmt-shared-prod-001" #data.azurerm_log_analytics_workspace.law.id
  image_publisher         = var.image_publisher
  image_offer             = var.image_offer
  image_sku               = var.image_sku
  image_version           = var.image_version
  tags                    = local.tags
  uai                     = data.azurerm_user_assigned_identity.key_vault.id
  key_vault_key_id        = "https://kv-<CaseyRemovedThisForThisExample>-mgmt-prod-001.vault.azure.net/keys/key-rsa-sub-test-int-${var.env}-001"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.77.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.77.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_disk_encryption_set.main](https://registry.terraform.io/providers/hashicorp/azurerm/3.77.0/docs/resources/disk_encryption_set) | resource |
| [azurerm_maintenance_assignment_virtual_machine.main](https://registry.terraform.io/providers/hashicorp/azurerm/3.77.0/docs/resources/maintenance_assignment_virtual_machine) | resource |
| [azurerm_maintenance_assignment_virtual_machine.main_prod_2](https://registry.terraform.io/providers/hashicorp/azurerm/3.77.0/docs/resources/maintenance_assignment_virtual_machine) | resource |
| [azurerm_managed_disk.data](https://registry.terraform.io/providers/hashicorp/azurerm/3.77.0/docs/resources/managed_disk) | resource |
| [azurerm_monitor_data_collection_rule.main](https://registry.terraform.io/providers/hashicorp/azurerm/3.77.0/docs/resources/monitor_data_collection_rule) | resource |
| [azurerm_monitor_data_collection_rule_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/3.77.0/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_network_interface.main](https://registry.terraform.io/providers/hashicorp/azurerm/3.77.0/docs/resources/network_interface) | resource |
| [azurerm_virtual_machine_data_disk_attachment.data](https://registry.terraform.io/providers/hashicorp/azurerm/3.77.0/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_extension.daa-agent](https://registry.terraform.io/providers/hashicorp/azurerm/3.77.0/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.guest_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/3.77.0/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.monitor-agent](https://registry.terraform.io/providers/hashicorp/azurerm/3.77.0/docs/resources/virtual_machine_extension) | resource |
| [azurerm_windows_virtual_machine.main](https://registry.terraform.io/providers/hashicorp/azurerm/3.77.0/docs/resources/windows_virtual_machine) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app"></a> [app](#input\_app) | Application specific information | `string` | n/a | yes |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | n/a | `list` | <pre>[<br>  "1",<br>  "2",<br>  "3"<br>]</pre> | no |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | The size in dbs for the disk | `string` | n/a | yes |
| <a name="input_disk_count"></a> [disk\_count](#input\_disk\_count) | Specifies the number of managed disk to create | `number` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment to build the infrastructure in: nonprod or prod | `string` | n/a | yes |
| <a name="input_image_offer"></a> [image\_offer](#input\_image\_offer) | Specifies the offer of the image used to create the virtual machine. | `string` | n/a | yes |
| <a name="input_image_publisher"></a> [image\_publisher](#input\_image\_publisher) | Specifies the publisher of the image used to create the virtual machine. | `string` | n/a | yes |
| <a name="input_image_sku"></a> [image\_sku](#input\_image\_sku) | Specifies the SKU of the image used to create the virtual machine. | `string` | n/a | yes |
| <a name="input_image_version"></a> [image\_version](#input\_image\_version) | Specifies the version of the image used to create the virtual machine. | `string` | n/a | yes |
| <a name="input_key_vault_key_id"></a> [key\_vault\_key\_id](#input\_key\_vault\_key\_id) | Specifies the URL to a Key Vault Key (either from a Key Vault Key, or the Key URL for the Key Vault Secret). | `string` | n/a | yes |
| <a name="input_law_id"></a> [law\_id](#input\_law\_id) | The Resource ID of the log analytics workspace to log to | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The azure region to build the resource in | `string` | n/a | yes |
| <a name="input_maintenance_configuration_id"></a> [maintenance\_configuration\_id](#input\_maintenance\_configuration\_id) | Specifies id prefix of the maintenance configuration. | `string` | `"/subscriptions/693220f0-f62a-45e7-a478-553e340e9296/resourceGroups/rg-mgmt-shared-prod-001/providers/Microsoft.Maintenance/maintenanceConfigurations/mc-"` | no |
| <a name="input_managed_disk_type"></a> [managed\_disk\_type](#input\_managed\_disk\_type) | Specifies disk type for managed disk | `string` | n/a | yes |
| <a name="input_os_disk_type"></a> [os\_disk\_type](#input\_os\_disk\_type) | (Required) The type of storage to use for the managed disk. Possible values are Standard\_LRS, StandardSSD\_ZRS, Premium\_LRS, PremiumV2\_LRS, Premium\_ZRS, StandardSSD\_LRS or UltraSSD\_LRS. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of resource group to deploy the resource into | `string` | n/a | yes |
| <a name="input_subnet_address_prefixes"></a> [subnet\_address\_prefixes](#input\_subnet\_address\_prefixes) | CIDRs of the subnet to deploy the virtual machine into | `list(string)` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Resource ID of the subnet to deploy the virtual machine into | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for resources | `map(string)` | n/a | yes |
| <a name="input_uai"></a> [uai](#input\_uai) | A User Assigned Managed Identity ID to be assigned to this Disk Encryption Set. | `string` | n/a | yes |
| <a name="input_vm_admin_password"></a> [vm\_admin\_password](#input\_vm\_admin\_password) | The VM password value | `string` | n/a | yes |
| <a name="input_vm_count"></a> [vm\_count](#input\_vm\_count) | The number of vms to deploy | `number` | n/a | yes |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | The vm series of the vms to deploy | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azurerm_network_interface"></a> [azurerm\_network\_interface](#output\_azurerm\_network\_interface) | The list of private ip addresses. |
| <a name="output_virtual_machine_id"></a> [virtual\_machine\_id](#output\_virtual\_machine\_id) | The list of virtual machine ids. |
<!-- END_TF_DOCS -->