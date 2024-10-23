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

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "hub_vnet" {
  name                = var.vnet_name_hub
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space_hub
  tags = {
    environment = "hub"
  }
}

resource "azurerm_virtual_network" "spoke_vnets" {
  for_each             = toset(var.vnet_name_spokes)
  name                 = each.value
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name
  address_space        = var.address_space_spokes[each.key]
  tags = {
    environment = "spoke"
  }
}

resource "azurerm_subnet" "appgw_subnet" {
  name                 = "appgw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnets["vnet-appgwlab-appgw"].name
  address_prefixes     = var.subnet_space_spokes["vnet-appgwlab-appgw"]
  depends_on           = [azurerm_virtual_network.spoke_vnets]
}

resource "azurerm_subnet" "appservice_subnet" {
  name                 = "appservice-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnets["vnet-appgwlab-appservice"].name
  address_prefixes     = var.subnet_space_spokes["vnet-appgwlab-appservice"]
  depends_on           = [azurerm_virtual_network.spoke_vnets]
}

resource "azurerm_subnet" "hub_fw_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = var.subnet_space_fw
  depends_on           = [azurerm_virtual_network.hub_vnet]
}

resource "azurerm_firewall_policy" "firewall_policy" {
  name                = "azfw-hub-policy"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
}

resource "azurerm_firewall_policy_rule_collection_group" "rcg" {
  name               = "demo-fwpolicy-rcg"
  firewall_policy_id = azurerm_firewall_policy.firewall_policy.id
  priority           = 500
  network_rule_collection {
    name     = "network_rule_collection1"
    priority = 400
    action   = "Allow"
    rule {
      name                  = "network_rule_collection1_rule1"
      protocols             = ["TCP", "UDP", "ICMP"]
      source_addresses      = ["10.0.0.0/8"]
      destination_addresses = ["10.0.0.0/8"]
      destination_ports     = ["*"]
    }
  }
}

resource "azurerm_firewall" "firewall" {
  name                = "azfw-hub"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.firewall_policy.id
  ip_configuration {
    name                          = "FirewallIpConfig"
    subnet_id                     = azurerm_subnet.hub_fw_subnet.id
    public_ip_address_id          = azurerm_public_ip.firewall.id
  }
}

resource "azurerm_public_ip" "firewall" {
  name                = "firewall-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network_peering" "hub_to_spokes" {
  for_each                  = toset(var.vnet_name_spokes)
  name                      = "peer-hub-to-${each.key}"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_vnets[each.key].id
}

resource "azurerm_virtual_network_peering" "spokes_to_hub" {
  for_each                  = toset(var.vnet_name_spokes)
  name                      = "peer-${each.key}-to-hub"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.spoke_vnets[each.key].name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id
  allow_forwarded_traffic   = true
}

resource "azurerm_route_table" "appservice_rt" {
  name                = "appgwlab-route-table-appservice"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  bgp_route_propagation_enabled = false
  route {
    name           = "default-route"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_route_table" "appgw_rt" {
  name                = "appgwlab-route-table-appgw"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  bgp_route_propagation_enabled = false
  route {
    name           = "private-route"
    address_prefix = "10.0.0.0/8"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }
  route {
    name           = "default-route"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "rt_association-appgw" {
  subnet_id = azurerm_subnet.appgw_subnet.id
  route_table_id = azurerm_route_table.appgw_rt.id
}

resource "azurerm_subnet_route_table_association" "rt_association_appservice" {
  subnet_id = azurerm_subnet.appservice_subnet.id
  route_table_id = azurerm_route_table.appservice_rt.id
}