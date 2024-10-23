terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "appgw_vnet" {
  name                = "vnet-appgwlab-appgw"
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "appservice_subnet" {
  name                 = "appservice-subnet"
  virtual_network_name = "vnet-appgwlab-appservice"
  resource_group_name  = var.resource_group_name
}

data "azurerm_subnet" "appgw_subnet" {
  name                 = "appgw-subnet"
  virtual_network_name = "vnet-appgwlab-appgw"
  resource_group_name  = var.resource_group_name
}

resource "azurerm_service_plan" "appserviceplan" {
  name                = "appgwlab-appserviceplan"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "app_service" {
  name                = var.app_service_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  service_plan_id = azurerm_service_plan.appserviceplan.id
  public_network_access_enabled = false

  site_config {}
}

resource "azurerm_private_endpoint" "app_service_pe" {
  name                = "${var.app_service_name}-pe"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.appservice_subnet.id

  private_service_connection {
    name                           = "${var.app_service_name}-psc"
    private_connection_resource_id = azurerm_linux_web_app.app_service.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "app_service_dns_zone_group"
    private_dns_zone_ids = [azurerm_private_dns_zone.app_service_dns_zone.id]
  }
}

resource "azurerm_private_dns_zone" "app_service_dns_zone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "app_service_dns_zone_link" {
  name                  = "appgw-vnet-link"
  resource_group_name   = data.azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.app_service_dns_zone.name
  virtual_network_id    = data.azurerm_virtual_network.appgw_vnet.id
}