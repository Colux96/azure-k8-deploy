# Output per gli ID delle NIC dei master
output "master_nic_ids" {
  value = azurerm_network_interface.master_nic[*].id
  description = "ID NIC nodi master"
}

# Output per gli ID delle NIC dei worker
output "worker_nic_ids" {
  value = azurerm_network_interface.worker_nic[*].id
  description = "ID NIC nodi worker"
}

# Output per gli IP pubblici dei nodi master
output "master_public_ips" {
  value = azurerm_public_ip.pubIP_master[*].ip_address
  description = "Gli indirizzi IP pubblici dei nodi master"
}

# Output per gli IP privati dei nodi master
output "master_private_ips" {
  value = [for nic in azurerm_network_interface.master_nic : nic.private_ip_address]
  description = "Gli indirizzi IP privati dei nodi master"
}

# Output per gli IP pubblici dei nodi worker
output "worker_public_ips" {
  value = azurerm_public_ip.pubIP_worker[*].ip_address
  description = "Gli indirizzi IP pubblici dei nodi worker"
}

# Output per gli IP privati dei nodi worker
output "worker_private_ips" {
  value = [for nic in azurerm_network_interface.worker_nic : nic.private_ip_address]
  description = "Gli indirizzi IP privati dei nodi worker"
}