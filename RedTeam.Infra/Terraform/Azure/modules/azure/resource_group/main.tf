provider "azurerm" {
  features {
    resource_group {
       prevent_deletion_if_contains_resources = false
     }
  }
}
resource "azurerm_resource_group" "rg" {
  name     = var.name 
  location = var.location 
  tags = {
    Owner = var.owner 
    #MyTag = "MyValue"
  }  
}