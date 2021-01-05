# hub
resource "azurerm_route_table" "eun_hub_main" {
    name                          = "eun_hub_main"
    location                      = azurerm_resource_group.eun_hub.location
    resource_group_name           = azurerm_resource_group.eun_hub.name
    disable_bgp_route_propagation = false

    route {
        name                      = "Default"
        address_prefix            = "0.0.0.0/0"
        next_hop_type             = "VirtualAppliance"
        next_hop_in_ip_address    = "10.0.4.4"
    }

    route {
        name                      = "withinSubnetHub"
        address_prefix            = "10.0.5.0/24"
        next_hop_type             = "VirtualAppliance"
        next_hop_in_ip_address    = "10.0.4.4"
    }

    route {
        name                      = "eun_spoke"
        address_prefix            = "10.0.6.0/24"
        next_hop_type             = "VirtualAppliance"
        next_hop_in_ip_address    = "10.0.4.4"
    }

    route {
        name                      = "uks_hub"
        address_prefix            = "10.0.1.0/24"
        next_hop_type             = "VirtualAppliance"
        next_hop_in_ip_address    = "10.0.4.4"
    }

    route {
        name                      = "uks_spoke"
        address_prefix            = "10.0.2.0/24"
        next_hop_type             = "VirtualAppliance"
        next_hop_in_ip_address    = "10.0.4.4"
    }
}

resource "azurerm_subnet_route_table_association" "eun_hub_main" {
    subnet_id                     = azurerm_virtual_network.eun_hub.subnet.*.id[2]
    route_table_id                = azurerm_route_table.eun_hub_main.id
}

resource "azurerm_route_table" "eun_hub_azfw" {
    name                          = "eun_hub_azfw"
    location                      = azurerm_resource_group.eun_hub.location
    resource_group_name           = azurerm_resource_group.eun_hub.name
    disable_bgp_route_propagation = false

    route {
        name                      = "AzureFirewallDefaultRoute"
        address_prefix            = "0.0.0.0/0"
        next_hop_type             = "Internet"
    }

    route {
        name                      = "eun"
        address_prefix            = "10.0.0.0/22"
        next_hop_type             = "VirtualAppliance"
        next_hop_in_ip_address    = "10.0.0.4"
    }

    route {
        name                      = "uks_subnetHub"
        address_prefix            = "10.0.1.0/24"
        next_hop_type             = "VirtualAppliance"
        next_hop_in_ip_address    = "10.0.0.4"
    }
}

resource "azurerm_subnet_route_table_association" "eun_hub_azfw" {
    subnet_id                     = azurerm_virtual_network.eun_hub.subnet.*.id[0]
    route_table_id                = azurerm_route_table.eun_hub_azfw.id
}

# spoke
resource "azurerm_route_table" "eun_spoke" {
    name                          = "eun_spoke"
    location                      = azurerm_resource_group.eun_hub.location
    resource_group_name           = azurerm_resource_group.eun_hub.name
    disable_bgp_route_propagation = false

    route {
        name                      = "Default"
        address_prefix            = "0.0.0.0/0"
        next_hop_type             = "VirtualAppliance"
        next_hop_in_ip_address    = "10.0.4.4"
    }

    route {
        name                      = "withinSubnetSpoke"
        address_prefix            = "10.0.6.0/24"
        next_hop_type             = "VirtualAppliance"
        next_hop_in_ip_address    = "10.0.4.4"
    }

    route {
        name                      = "eun_hub"
        address_prefix            = "10.0.5.0/24"
        next_hop_type             = "VirtualAppliance"
        next_hop_in_ip_address    = "10.0.4.4"
    }
}

resource "azurerm_subnet_route_table_association" "eun_spoke" {
    subnet_id                     = azurerm_virtual_network.eun_hub.subnet.*.id[0]
    route_table_id                = azurerm_route_table.eun_spoke.id
}