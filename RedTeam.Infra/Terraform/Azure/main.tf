terraform {
  backend "local" {
  }
}

provider "azurerm" {
    features {}
    #skip_provider_registration = true
}

variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "users" {
  type = list(string)
}

variable "owner" {
  type = string
}

# Create RG
module "resource_group" {
  source = "./modules/azure/resource_group"
  name = var.name
  owner = var.owner
}

# Create the VNET, Subnet, and NSG 
module "network" {
  source = "./modules/azure/network"
  name = var.name
}

# Windows VM Deployment
module "vm" {
  source         = "./modules/azure/vm_win"
  name           = var.name
  location       = var.location
  instance_count = length(var.users)
  users          = var.users
  subnet_id      = module.network.azurerm_subnet
}