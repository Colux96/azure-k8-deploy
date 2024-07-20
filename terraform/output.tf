output "public_ip_address" {
  description = "IP publico della macchina virtuale creata."
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}