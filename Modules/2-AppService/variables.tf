variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Location of Azure resource"
  default     = "eastus2"
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
}

variable "app_service_name" {
  description = "Name of the App Service"
  type        = string
}