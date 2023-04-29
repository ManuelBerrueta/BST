provider "azurerm" {
    features {}
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${upper(var.name)}-vnet"
  address_space       = ["10.0.0.0/8"]
  location            = var.location 
  resource_group_name = var.name 
  tags = {
    #MyTag = "MyValue"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet00"
  resource_group_name  = var.name 
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = ["10.1.0.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name}_nsg"
  location            = var.location 
  resource_group_name = var.name 

  security_rule {
    name                       = "Allow_RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = ["Your Pub IP"]
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow_SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = ["You Pub IP"]
    destination_address_prefix = "*"
  }
  tags = {
    #MyTag = "MyTag"
  }
}

# This deadlocks
#resource "azurerm_subnet_network_security_group_association" "nsg_association" {
#  subnet_id                 = azurerm_subnet.subnet.id
#  network_security_group_id = azurerm_network_security_group.nsg.id
#}
