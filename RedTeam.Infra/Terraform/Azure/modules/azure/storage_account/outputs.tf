output storage_key {
  value = azurerm_storage_account.storage.primary_connection_string
  sensitive = false
}