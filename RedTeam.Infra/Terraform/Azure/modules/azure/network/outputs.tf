output "azurerm_virtual_network" {
  value = "${azurerm_virtual_network.vnet.name}"
}

output "azurerm_virtual_network_location" {
  value = "${azurerm_virtual_network.vnet.location}"
}

output "azurerm_subnet" {
  value = "${azurerm_subnet.subnet.id}"
}

output "azurerm_nsg" {
  value = "${azurerm_network_security_group.nsg.id}"
}
