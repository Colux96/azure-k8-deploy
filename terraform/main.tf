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
  nic_name            = var.nic_name
  vm_total_count      = var.vm_total_count
  master_count        = var.master_count
  worker_count        = var.worker_count
  resource_group_name = var.resource_group_name
  location            = var.location
}

#Crea risorse Macchine virtuali dal modulo
module "vm" {
  source                = "./modules/vm"
  resource_group_name   = var.resource_group_name
  network_id            = module.network.network_id
  location              = var.location
  master_count          = var.master_count
  worker_count          = var.worker_count
  vm_size               = var.vm_size
  vm_name               = var.vm_name
  vm_admin_user         = var.vm_admin_user
  vm_admin_password     = var.vm_admin_password 
}

#TODO: Aggiungere modulo per la creazione del cluster kubernetes