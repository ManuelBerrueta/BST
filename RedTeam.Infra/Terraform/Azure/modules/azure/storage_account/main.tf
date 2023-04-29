resource "random_string" "storage_name" {
  length          = 8
  special         = false
  upper           = false
  number          = false
}

resource "azurerm_storage_account" "storage" {
  name                  = resource.random_string.storage_name.result
  resource_group_name   = module.resource_group.resource_group_name
  location              = var.location
  account_tier          = "Standard"
  min_tls_version       = "TLS1_0"
  account_replication_type = "LRS"
}