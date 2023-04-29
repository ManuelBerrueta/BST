output "ips" {
  value = ["${azurerm_public_ip.pip.*.ip_address}"]
}

output "users" {
  value = ["${var.users}"]
}

output "password" {
  value = ["${random_string.password.result}"]
}