provider "azurerm" {
    features {}
}

resource "azurerm_public_ip" "pip" {
  count                        = var.instance_count
  name                         = "${upper(var.name)}NIX${count.index}_pip"
  location                     = var.location
  resource_group_name          = var.name
  allocation_method            = "Static"
}

resource "azurerm_network_interface" "nic" {
  count                     = var.instance_count
  name                      = "${upper(var.name)}NIX${count.index}_nic"
  location                  = var.location
  resource_group_name       = var.name

  ip_configuration {
    name                          = "${upper(var.opname)}NIX${count.index}_nic_config"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = element(azurerm_public_ip.pip.*.id, count.index)
  }
}

resource "azurerm_linux_virtual_machine" "linux" {
  count                 = var.instance_count
  name                  = "${upper(var.opname)}NIXVM${count.index}"
  location              = var.location
  resource_group_name   = var.name
  network_interface_ids = [element(azurerm_network_interface.nic.*.id, count.index)]
  size                  = var.size
  admin_username        = var.users
  
  disable_password_authentication   = true
  allow_extension_operations        = false
  
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  
  os_disk {
    name                  = "${upper(var.name)}NIXVM${count.index}_disk"
    caching               = "ReadWrite"
    storage_account_type  = "Standard_LRS"
  }

  admin_ssh_key {
    username        = var.users
    public_key      = file(var.ssh_key_path)
  }
}
