terraform {
  required_version = ">= 1.9.2"
}

#Crea un gruppo di risorse
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

#Crea risorse Network dal modulo
module "network" {
  source              = "./modules/network"
  vnet_name           = var.vnet_name
  snet_name           = var.snet_name
  nsg_name            = var.nsg_name
  vm_total_count      = var.vm_total_count
  master_count        = var.master_count
  worker_count        = var.worker_count
  resource_group_name = var.resource_group_name
  location            = var.location

  depends_on = [azurerm_resource_group.rg]
}

#Crea risorse Macchine virtuali dal modulo
module "vm" {
  source                = "./modules/vm"
  resource_group_name   = var.resource_group_name
  master_nic_ids        = module.network.master_nic_ids
  worker_nic_ids        = module.network.worker_nic_ids 
  location              = var.location
  master_count          = var.master_count
  worker_count          = var.worker_count
  vm_size               = var.vm_size
  vm_name               = var.vm_name
  vm_admin_user         = var.vm_admin_user
  vm_admin_password     = var.vm_admin_password 

  depends_on = [module.network]
}


#Configura il namespace richiesto e crea il job di benchmark utilizzando kube-bench
module "benchmark" {
  source              = "./modules/benchmark"
  namespace_name      = var.namespace_name
}
