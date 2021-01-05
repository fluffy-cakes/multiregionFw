# uks
# hub
resource "azurerm_virtual_network" "uks_hub" {
    name                      = "uks_hub"
    location                  = azurerm_resource_group.uks_hub.location
    resource_group_name       = azurerm_resource_group.uks_hub.name
    address_space             = ["10.0.0.0/23"]
}

resource "azurerm_subnet" "uks_hub_AzureFirewallSubnet" {
    name                      = "AzureFirewallSubnet"
    resource_group_name       = azurerm_virtual_network.uks_hub.resource_group_name
    virtual_network_name      = azurerm_virtual_network.uks_hub.name
    address_prefixes          = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "uks_hub_subnetHub" {
    name                      = "subnetHub"
    resource_group_name       = azurerm_virtual_network.uks_hub.resource_group_name
    virtual_network_name      = azurerm_virtual_network.uks_hub.name
    address_prefixes          = ["10.0.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "uks_hub_subnetHub" {
    subnet_id                 = azurerm_subnet.uks_hub_subnetHub.id
    network_security_group_id = azurerm_network_security_group.uks_hub.id
}

# spoke
resource "azurerm_virtual_network" "uks_spoke" {
    name                      = "uks_spoke"
    location                  = azurerm_resource_group.uks_spoke.location
    resource_group_name       = azurerm_resource_group.uks_spoke.name
    address_space             = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "uks_spoke_subnetSpoke" {
    name                      = "subnetSpoke"
    resource_group_name       = azurerm_virtual_network.uks_spoke.resource_group_name
    virtual_network_name      = azurerm_virtual_network.uks_spoke.name
    address_prefixes          = ["10.0.2.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "uks_spoke_subnetSpoke" {
    subnet_id                 = azurerm_subnet.uks_spoke_subnetSpoke.id
    network_security_group_id = azurerm_network_security_group.uks_spoke.id
}


# eun
# hub
resource "azurerm_virtual_network" "eun_hub" {
    name                      = "eun_hub"
    location                  = azurerm_resource_group.eun_hub.location
    resource_group_name       = azurerm_resource_group.eun_hub.name
    address_space             = ["10.0.4.0/23"]
}

resource "azurerm_subnet" "eun_hub_AzureFirewallSubnet" {
    name                      = "AzureFirewallSubnet"
    resource_group_name       = azurerm_virtual_network.eun_hub.resource_group_name
    virtual_network_name      = azurerm_virtual_network.eun_hub.name
    address_prefixes          = ["10.0.4.0/24"]
}

resource "azurerm_subnet" "eun_hub_subnetHub" {
    name                      = "subnetHub"
    resource_group_name       = azurerm_virtual_network.eun_hub.resource_group_name
    virtual_network_name      = azurerm_virtual_network.eun_hub.name
    address_prefixes          = ["10.0.5.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "eun_hub_subnetHub" {
    subnet_id                 = azurerm_subnet.eun_hub_subnetHub.id
    network_security_group_id = azurerm_network_security_group.eun_hub.id
}

# spoke
resource "azurerm_virtual_network" "eun_spoke" {
    name                      = "eun_spoke"
    location                  = azurerm_resource_group.eun_spoke.location
    resource_group_name       = azurerm_resource_group.eun_spoke.name
    address_space             = ["10.0.6.0/24"]
}

resource "azurerm_subnet" "eun_spoke_subnetSpoke" {
    name                      = "subnetSpoke"
    resource_group_name       = azurerm_virtual_network.eun_spoke.resource_group_name
    virtual_network_name      = azurerm_virtual_network.eun_spoke.name
    address_prefixes          = ["10.0.6.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "eun_spoke_subnetSpoke" {
    subnet_id                 = azurerm_subnet.eun_spoke_subnetSpoke.id
    network_security_group_id = azurerm_network_security_group.eun_spoke.id
}