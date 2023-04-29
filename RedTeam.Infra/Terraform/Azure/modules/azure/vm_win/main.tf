provider "azurerm" {
  features{}
}

resource "azurerm_network_interface" "nic" {
  count               = var.instance_count
  name                = "${upper(var.name)}VM${count.index}_nic"
  location            = var.location
  resource_group_name = var.name
  
  ip_configuration {
    name                          = "${upper(var.name)}VM${count.index}_nic_config"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.pip.*.id, count.index)
  }
}

resource "azurerm_public_ip" "pip" {
  count                        = var.instance_count
  name                         = "${upper(var.name)}VM${count.index}_pip"
  location                     = var.location
  resource_group_name          = var.name
  allocation_method            = "Static"
}

resource "random_string" "password" {
  length  = 24
  upper   = true
  lower   = true
  numeric  = true
  special = true
}

resource "azurerm_virtual_machine" "win-vm" {
  count                 = var.instance_count
  name                  = "${upper(var.name)}VM${count.index}"
  location              = var.location 
  resource_group_name   = var.name 
  network_interface_ids = [element(azurerm_network_interface.nic.*.id, count.index)]
  vm_size               = var.size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  
  storage_os_disk {
    name              = "${upper(var.name)}VM${count.index}_disk" 
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  
  os_profile {
    computer_name  = "${upper(var.name)}VM${count.index}" 
    admin_username = var.users[count.index]
    admin_password = random_string.password.result
  }
  
  os_profile_windows_config {
    #enable_automatic_upgrades = true
    #provision_vm_agent        = true
  }
}