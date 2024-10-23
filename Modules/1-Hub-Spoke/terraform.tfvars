subscription_id = "<subID>"
resource_group_name = "<rgName>"
location = "<location>"
vnet_name_hub           = "vnet-appgwlab-hub"
vnet_name_spokes        = ["vnet-appgwlab-appservice", "vnet-appgwlab-appgw"]
address_space_hub       = ["10.1.0.0/16"]
subnet_space_fw        = ["10.1.1.0/24"]
address_space_spokes    = {
  "vnet-appgwlab-appservice" = ["10.2.0.0/24"],
  "vnet-appgwlab-appgw"  = ["10.3.0.0/24"]
}
subnet_space_spokes     = {
  "vnet-appgwlab-appservice" = ["10.2.0.0/27"],
  "vnet-appgwlab-appgw"  = ["10.3.0.0/24"]
}