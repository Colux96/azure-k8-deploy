# Crea N macchine virtuali di tipo Master
  resource "azurerm_virtual_machine" "k8s_master" {
    count                 = var.master_count
    name                  = "${var.vm_name}-master-${count.index}"
    location              = var.location
    resource_group_name   = var.resource_group_name
    network_interface_ids = [var.network_id]
    vm_size               = var.vm_size
    
    storage_os_disk {
      name                 = "MasterDisk-${count.index}"
      caching              = "ReadWrite"
      create_option        = "FromImage"
      managed_disk_type    = "Standard_LRS"
      disk_size_gb         = 30
    }

    storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
    }

    os_profile {
    computer_name  = "${var.vm_name}-master-${count.index}"
    admin_username = var.vm_admin_user
    admin_password = var.vm_admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

}

resource "azurerm_virtual_machine" "k8s_worker" {
  count                 = var.worker_count
  name                  = "${var.vm_name}-worker-${count.index}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [var.network_id]
  vm_size               = var.vm_size

  storage_os_disk {
      name                 = "WorkerDisk-${count.index}"
      caching              = "ReadWrite"
      create_option        = "FromImage"
      managed_disk_type    = "Standard_LRS"
      disk_size_gb         = 30
    }

    storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
    }

    os_profile {
    computer_name  = "${var.vm_name}-worker-${count.index}"
    admin_username = var.vm_admin_user
    admin_password = var.vm_admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

}