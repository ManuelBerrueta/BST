output vm_ips {
  value = [module.vm.ips]
}

output vm_admin_password {
  value = [module.vm.password]
}