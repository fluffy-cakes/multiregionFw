provider "azurerm" {
    features {}
}

terraform {
    backend "azurerm" {
        access_key               = "Fzs2rUmWv9qo/OotuSPo7Rc4ZdiVGst0zsQQ3PyN8lTck08O52k4ql5BPPwH9nxDiy/b7nkr3OtfXcmXe29JlQ=="
        container_name           = "tfstate"
        key                      = "main.tfstate"
        storage_account_name     = "nbstestbackend"
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


# virtual networks
resource "azurerm_virtual_network" "uks_hub" {
    name                         = "uks_hub"
    location                     = azurerm_resource_group.uks_hub.location
    resource_group_name          = azurerm_resource_group.uks_hub.name
    address_space                = ["10.0.0.0/23"]

    subnet {
        name                     = "AzureFirewallSubnet"
        address_prefix           = "10.0.0.0/24"
    }

    subnet {
        name                     = "subnetHub"
        address_prefix           = "10.0.1.0/24"
        security_group           = azurerm_network_security_group.uks_hub.id
    }
}

resource "azurerm_virtual_network" "uks_spoke" {
    name                         = "uks_spoke"
    location                     = azurerm_resource_group.uks_spoke.location
    resource_group_name          = azurerm_resource_group.uks_spoke.name
    address_space                = ["10.0.2.0/24"]

    subnet {
        name                     = "subnetSpoke"
        address_prefix           = "10.0.2.0/24"
        security_group           = azurerm_network_security_group.uks_spoke.id
    }
}

resource "azurerm_virtual_network" "eun_hub" {
    name                         = "eun_hub"
    location                     = azurerm_resource_group.eun_hub.location
    resource_group_name          = azurerm_resource_group.eun_hub.name
    address_space                = ["10.0.4.0/23"]

    subnet {
        name                     = "AzureFirewallSubnet"
        address_prefix           = "10.0.4.0/24"
    }

    subnet {
        name                     = "subnetHub"
        address_prefix           = "10.0.5.0/24"
        security_group           = azurerm_network_security_group.eun_hub.id
    }
}

resource "azurerm_virtual_network" "eun_spoke" {
    name                         = "eun_spoke"
    location                     = azurerm_resource_group.eun_spoke.location
    resource_group_name          = azurerm_resource_group.eun_spoke.name
    address_space                = ["10.0.6.0/24"]

    subnet {
        name                     = "subnetSpoke"
        address_prefix           = "10.0.6.0/24"
        security_group           = azurerm_network_security_group.eun_spoke.id
    }
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


# ubuntu vms
module "ub_uks_hub" {
    source                       = "./ubuntu"
    env                          = "uks_hub"
    rg_location                  = azurerm_resource_group.uks_hub.location
    rg_name                      = azurerm_resource_group.uks_hub.name
    subnet                       = azurerm_virtual_network.uks_hub.subnet.*.id[1]
}

module "ub_uks_spoke" {
    source                       = "./ubuntu"
    env                          = "uks_spoke"
    rg_location                  = azurerm_resource_group.uks_spoke.location
    rg_name                      = azurerm_resource_group.uks_spoke.name
    subnet                       = azurerm_virtual_network.uks_spoke.subnet.*.id[0]
}

module "ub_eun_hub" {
    source                       = "./ubuntu"
    env                          = "eun_hub"
    rg_location                  = azurerm_resource_group.eun_hub.location
    rg_name                      = azurerm_resource_group.eun_hub.name
    subnet                       = azurerm_virtual_network.eun_hub.subnet.*.id[1]
}

module "ub_eun_spoke" {
    source                       = "./ubuntu"
    env                          = "eun_spoke"
    rg_location                  = azurerm_resource_group.eun_spoke.location
    rg_name                      = azurerm_resource_group.eun_spoke.name
    subnet                       = azurerm_virtual_network.eun_spoke.subnet.*.id[0]
}