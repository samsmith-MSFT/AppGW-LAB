variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Location of Azure resource"
  default     = "eastus2"
  type        = string
}

variable "vnet_name_hub" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_space_hub" {
  description = "Address space of the virtual network"
  type        = list(string)
}

variable "subnet_space_fw" {
  description = "Subnet space of the virtual network"
  type        = list(string)
}

variable "vnet_name_spokes" {
  description = "Name of the virtual network"
  type        = list(string)
}

variable "address_space_spokes" {
  description = "Address space of the virtual network"
  type        = map(list(string))
}

variable "subnet_space_spokes" {
  description = "Subnet space of the virtual network"
  type        = map(list(string))
}

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
}