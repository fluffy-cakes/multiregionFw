variable env {}
variable rg_location {}
variable rg_name {}
variable subnet {}


resource "azurerm_network_interface" "ubuntu" {
    name                              = replace("ubuntu-${var.env}", "_", "-")
    location                          = var.rg_location
    resource_group_name               = var.rg_name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = var.subnet
        private_ip_address_allocation = "Dynamic"
    }
}

    resource "azurerm_linux_virtual_machine" "ubuntu" {
    name                              = replace("ubuntu-${var.env}", "_", "-")
    resource_group_name               = var.rg_name
    location                          = var.rg_location
    size                              = "Standard_B2ms"
    admin_username                    = "adminuser"
    admin_password                    = "$loppy0ats!"
    disable_password_authentication   = false
    network_interface_ids             = [
        azurerm_network_interface.ubuntu.id
    ]

    os_disk {
        caching                       = "ReadWrite"
        storage_account_type          = "Standard_LRS"
    }

    source_image_reference {
        publisher                     = "Canonical"
        offer                         = "UbuntuServer"
        sku                           = "18.04-LTS"
        version                       = "latest"
    }
}

output private_ip_address {
    value                             = azurerm_network_interface.ubuntu.private_ip_address
}