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

data "azurerm_linux_web_app" "linux_web_app" {
  name                = var.app_service_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_virtual_network" "appgw_vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "appgw_subnet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.appgw_vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

resource "azurerm_public_ip" "appgw_public_ip" {
  name                = "appgw-public-ip"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "app_gateway" {
  name                = "my-app-gateway"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = data.azurerm_subnet.appgw_subnet.id
  }

  frontend_ip_configuration {
    name                 = "my-frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.appgw_public_ip.id
  }

  frontend_port {
    name = "frontend-port-80"
    port = 80
  }

  frontend_port {
    name = "frontend-port-443"
    port = 443
  }

  backend_address_pool {
    fqdns = ["${var.app_service_name}.azurewebsites.net"]
    name  = "my-backend-pool"
  }

  backend_http_settings {
    name                  = "my-backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "my-http-listener"
    frontend_ip_configuration_name = "my-frontend-ip-configuration"
    frontend_port_name             = "frontend-port-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "my-routing-rule"
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = "my-http-listener"
    backend_address_pool_name  = "my-backend-pool"
    backend_http_settings_name = "my-backend-http-settings"
  }

  waf_configuration {
    enabled            = true
    firewall_mode      = "Prevention"
    rule_set_type      = "OWASP"
    rule_set_version   = "3.2"
  }
}