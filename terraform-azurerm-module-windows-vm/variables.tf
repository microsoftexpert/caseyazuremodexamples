
variable "env" {
  description = "Environment to build the infrastructure in: nonprod or prod"
  type        = string
}

variable "location" {
  description = "The azure region to build the resource in"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Tags for resources"
}

variable "app" {
  type        = string
  description = "Application specific information"
}

variable "resource_group_name" {
  type        = string
  description = "Name of resource group to deploy the resource into"
}

variable "vm_count" {
  type        = number
  description = "The number of vms to deploy"
}

variable "vm_size" {
  type        = string
  description = "The vm series of the vms to deploy"
}

variable "os_disk_size" {
  description = "The size of the OS disk in GB"
  type        = number
  default     = 127  # Optional: Set a default size (e.g., 128 GB)
}

variable "availability_zone" {
  #There are only 3 availability zones per region currently
  default = ["1", "2", "3"]
}

variable "subnet_id" {
  type        = string
  description = "Resource ID of the subnet to deploy the virtual machine into"
}

variable "subnet_address_prefixes" {
  type        = list(string)
  description = "CIDRs of the subnet to deploy the virtual machine into"
}

variable "data_disk_size" {
  type        = string
  description = "The size in dbs for the disk"
}

variable "os_disk_type" {
  type        = string
  description = "(Required) The type of storage to use for the managed disk. Possible values are Standard_LRS, StandardSSD_ZRS, Premium_LRS, PremiumV2_LRS, Premium_ZRS, StandardSSD_LRS or UltraSSD_LRS."
}

variable "disk_count" {
  type        = number
  description = "Specifies the number of managed disk to create"
}

variable "managed_disk_type" {
  type        = string
  description = "Specifies disk type for managed disk"
}
variable "vm_admin_password" {
  type        = string
  description = "The VM password value"
}

variable "law_id" {
  type        = string
  description = "The Resource ID of the log analytics workspace to log to"
}

variable "image_publisher" {
  type        = string
  description = "Specifies the publisher of the image used to create the virtual machine."
}

variable "image_offer" {
  type        = string
  description = "Specifies the offer of the image used to create the virtual machine."
}

variable "image_sku" {
  type        = string
  description = "Specifies the SKU of the image used to create the virtual machine."
}

variable "image_version" {
  type        = string
  description = "Specifies the version of the image used to create the virtual machine."
}

variable "maintenance_configuration_id" {
  type        = string
  description = "Specifies id prefix of the maintenance configuration."
  default     = "/subscriptions/<CaseyRemovedIDForThisExample>/resourceGroups/rg-mgmt-shared-prod-001/providers/Microsoft.Maintenance/maintenanceConfigurations/mc-"
}

variable "key_vault_key_id" {
  type        = string
  description = "Specifies the URL to a Key Vault Key (either from a Key Vault Key, or the Key URL for the Key Vault Secret)."
}

variable "uai" {
  type        = string
  description = "A User Assigned Managed Identity ID to be assigned to this Disk Encryption Set."
}
