provider "azurerm" {
    features {}
}

terraform {
    backend "azurerm" {
        access_key               = "asdf"
        container_name           = "tfstate"
        key                      = "main.tfstate"
        storage_account_name     = "asdf"
    }
}

# resource groups
resource "azurerm_resource_group" "uks_hub" {
    name                         = "uks_hub"
    location                     = "uksouth"
}

resource "azurerm_resource_group" "uks_spoke" {
    name                         = "uks_spoke"
    location                     = "uksouth"
}

resource "azurerm_resource_group" "eun_hub" {
    name                         = "eun_hub"
    location                     = "northeurope"
}

resource "azurerm_resource_group" "eun_spoke" {
    name                         = "eun_spoke"
    location                     = "northeurope"
}


# network security groups
resource "azurerm_network_security_group" "uks_hub" {
    name                         = "uks_hub"
    location                     = azurerm_resource_group.uks_hub.location
    resource_group_name          = azurerm_resource_group.uks_hub.name
}

resource "azurerm_network_security_group" "uks_spoke" {
    name                         = "uks_spoke"
    location                     = azurerm_resource_group.uks_spoke.location
    resource_group_name          = azurerm_resource_group.uks_spoke.name
}

resource "azurerm_network_security_group" "eun_hub" {
    name                         = "eun_hub"
    location                     = azurerm_resource_group.eun_hub.location
    resource_group_name          = azurerm_resource_group.eun_hub.name
}

resource "azurerm_network_security_group" "eun_spoke" {
    name                         = "eun_spoke"
    location                     = azurerm_resource_group.eun_spoke.location
    resource_group_name          = azurerm_resource_group.eun_spoke.name
}


# virtual network peerings
# hubs
resource "azurerm_virtual_network_peering" "uks_hub" {
    name                         = "eun_hub"
    resource_group_name          = azurerm_virtual_network.uks_hub.resource_group_name
    virtual_network_name         = azurerm_virtual_network.uks_hub.name
    remote_virtual_network_id    = azurerm_virtual_network.eun_hub.id
    allow_forwarded_traffic      = true
    allow_gateway_transit        = true
    allow_virtual_network_access = true
    use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "eun_hub" {
    name                         = "uks_hub"
    resource_group_name          = azurerm_virtual_network.eun_hub.resource_group_name
    virtual_network_name         = azurerm_virtual_network.eun_hub.name
    remote_virtual_network_id    = azurerm_virtual_network.uks_hub.id
    allow_forwarded_traffic      = true
    allow_gateway_transit        = true
    allow_virtual_network_access = true
    use_remote_gateways          = false
}

# uks hub spoke
resource "azurerm_virtual_network_peering" "uks_hubSpoke" {
    name                         = "uks_spoke"
    resource_group_name          = azurerm_virtual_network.uks_hub.resource_group_name
    virtual_network_name         = azurerm_virtual_network.uks_hub.name
    remote_virtual_network_id    = azurerm_virtual_network.uks_spoke.id
    allow_forwarded_traffic      = true
    allow_gateway_transit        = true
    allow_virtual_network_access = true
    use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "uks_spokeHub" {
    name                         = "uks_hub"
    resource_group_name          = azurerm_virtual_network.uks_spoke.resource_group_name
    virtual_network_name         = azurerm_virtual_network.uks_spoke.name
    remote_virtual_network_id    = azurerm_virtual_network.uks_hub.id
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    allow_virtual_network_access = true
    use_remote_gateways          = false
}

# eun hub spoke
resource "azurerm_virtual_network_peering" "eun_hubSpoke" {
    name                         = "eun_spoke"
    resource_group_name          = azurerm_virtual_network.eun_hub.resource_group_name
    virtual_network_name         = azurerm_virtual_network.eun_hub.name
    remote_virtual_network_id    = azurerm_virtual_network.eun_spoke.id
    allow_forwarded_traffic      = true
    allow_gateway_transit        = true
    allow_virtual_network_access = true
    use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "eun_spokeHub" {
    name                         = "eun_hub"
    resource_group_name          = azurerm_virtual_network.eun_spoke.resource_group_name
    virtual_network_name         = azurerm_virtual_network.eun_spoke.name
    remote_virtual_network_id    = azurerm_virtual_network.eun_hub.id
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    allow_virtual_network_access = true
    use_remote_gateways          = false
}


# azure firewall
resource "azurerm_public_ip" "uks_hub" {
    name                         = "uks_hub_fw"
    location                     = azurerm_resource_group.uks_hub.location
    resource_group_name          = azurerm_resource_group.uks_hub.name
    allocation_method            = "Static"
    domain_name_label            = "uks-hub-nbstest"
    sku                          = "Standard"
}

resource "azurerm_firewall" "uks_hub" {
    name                         = "uks_hub"
    location                     = azurerm_resource_group.uks_hub.location
    resource_group_name          = azurerm_resource_group.uks_hub.name

    ip_configuration {
        name                     = "uks_hub"
        subnet_id                = azurerm_subnet.uks_hub_AzureFirewallSubnet.id
        public_ip_address_id     = azurerm_public_ip.uks_hub.id
    }
}

resource "azurerm_firewall_network_rule_collection" "uks_hub" {
    name                         = "any"
    azure_firewall_name          = azurerm_firewall.uks_hub.name
    resource_group_name          = azurerm_firewall.uks_hub.resource_group_name
    priority                     = "100"
    action                       = "Allow"

    rule {
        description              = "Any"
        destination_addresses    = ["*"]
        destination_ports        = ["*"]
        name                     = "Any"
        protocols                = ["Any"]
        source_addresses         = ["*"]
    }
}

    resource "azurerm_firewall_nat_rule_collection" "uks_spoke" {
    name                         = "ssh"
    azure_firewall_name          = azurerm_firewall.uks_hub.name
    resource_group_name          = azurerm_firewall.uks_hub.resource_group_name
    priority                     = 100
    action                       = "Dnat"

    rule {
        destination_addresses    = [azurerm_public_ip.uks_hub.ip_address]
        destination_ports        = ["22"]
        name                     = "ssh"
        protocols                = ["TCP","UDP",]
        source_addresses         = ["*"]
        translated_address       = module.ub_uks_spoke.private_ip_address
        translated_port          = 22
    }
}

resource "azurerm_public_ip" "eun_hub" {
    name                         = "eun_hub_fw"
    location                     = azurerm_resource_group.eun_hub.location
    resource_group_name          = azurerm_resource_group.eun_hub.name
    allocation_method            = "Static"
    domain_name_label            = "eun-hub-nbstest"
    sku                          = "Standard"
}

resource "azurerm_firewall" "eun_hub" {
    name                         = "eun_hub"
    location                     = azurerm_resource_group.eun_hub.location
    resource_group_name          = azurerm_resource_group.eun_hub.name

    ip_configuration {
        name                     = "eun_hub"
        subnet_id                = azurerm_subnet.eun_hub_AzureFirewallSubnet.id
        public_ip_address_id     = azurerm_public_ip.eun_hub.id
    }
}

resource "azurerm_firewall_network_rule_collection" "eun_hub" {
    name                         = "any"
    azure_firewall_name          = azurerm_firewall.eun_hub.name
    resource_group_name          = azurerm_firewall.eun_hub.resource_group_name
    priority                     = "100"
    action                       = "Allow"

    rule {
        description              = "Any"
        destination_addresses    = ["*"]
        destination_ports        = ["*"]
        name                     = "Any"
        protocols                = ["Any"]
        source_addresses         = ["*"]
    }
}

    resource "azurerm_firewall_nat_rule_collection" "eun_spoke" {
    name                         = "ssh"
    azure_firewall_name          = azurerm_firewall.eun_hub.name
    resource_group_name          = azurerm_firewall.eun_hub.resource_group_name
    priority                     = 100
    action                       = "Dnat"

    rule {
        destination_addresses    = [azurerm_public_ip.eun_hub.ip_address]
        destination_ports        = ["22"]
        name                     = "ssh"
        protocols                = ["TCP","UDP",]
        source_addresses         = ["*"]
        translated_address       = module.ub_eun_spoke.private_ip_address
        translated_port          = 22
    }
}


# ubuntu vms
module "ub_uks_hub" {
    source                       = "./ubuntu"
    env                          = "uks_hub"
    rg_location                  = azurerm_resource_group.uks_hub.location
    rg_name                      = azurerm_resource_group.uks_hub.name
    subnet                       = azurerm_subnet.uks_hub_subnetHub.id
}

module "ub_uks_spoke" {
    source                       = "./ubuntu"
    env                          = "uks_spoke"
    rg_location                  = azurerm_resource_group.uks_spoke.location
    rg_name                      = azurerm_resource_group.uks_spoke.name
    subnet                       = azurerm_subnet.uks_spoke_subnetSpoke.id
}

module "ub_eun_hub" {
    source                       = "./ubuntu"
    env                          = "eun_hub"
    rg_location                  = azurerm_resource_group.eun_hub.location
    rg_name                      = azurerm_resource_group.eun_hub.name
    subnet                       = azurerm_subnet.eun_hub_subnetHub.id
}

module "ub_eun_spoke" {
    source                       = "./ubuntu"
    env                          = "eun_spoke"
    rg_location                  = azurerm_resource_group.eun_spoke.location
    rg_name                      = azurerm_resource_group.eun_spoke.name
    subnet                       = azurerm_subnet.eun_spoke_subnetSpoke.id
}

output azfw_eun_hub { value      = azurerm_public_ip.eun_hub.ip_address   }
output azfw_uks_hub { value      = azurerm_public_ip.uks_hub.ip_address   }
output ub_eun_hub   { value      = module.ub_eun_hub.private_ip_address   }
output ub_eun_spoke { value      = module.ub_eun_spoke.private_ip_address }
output ub_uks_hub   { value      = module.ub_uks_hub.private_ip_address   }
output ub_uks_spoke { value      = module.ub_uks_spoke.private_ip_address }