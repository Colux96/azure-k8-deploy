# Crea una virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Crea una subnet
resource "azurerm_subnet" "snet" {
  name                 = var.snet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [azurerm_virtual_network.vnet]
}

# Crea un IP publico per il nodo master
resource "azurerm_public_ip" "pubIP_master" {
  count               = var.master_count
  name                = "public-ip-master-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

# Crea IP pubblici per i nodi worker
resource "azurerm_public_ip" "pubIP_worker" {
  count               = var.worker_count
  name                = "public-ip-worker-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}


# Crea Network Security Group con le regole di rete in ingresso
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

 # Regola per SSH
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Regola per la porta 6443 (porta API di Kubernetes)
  security_rule {
    name                       = "KUBERNETES-API"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Regola per la porta 30880 - Phpmyadmin
  security_rule {
    name                       = "HTTP-30880"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30880"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Regola per la porta 30080 - Nginx
  security_rule {
    name                       = "HTTP-30080"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

# Crea una NIC per nodo di tipo master
resource "azurerm_network_interface" "master_nic" {
  count               = var.master_count
  name                = "master-nic-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig-master-${count.index}"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pubIP_master[count.index].id

  }
}

# Crea una NIC per nodo di tipo worker
resource "azurerm_network_interface" "worker_nic" {
      count                = var.worker_count
      name                 = "worker-nic-${count.index}"
      location            = var.location
      resource_group_name = var.resource_group_name

      ip_configuration {
        name                          = "ipconfig-worker-${count.index}"
        subnet_id                     = azurerm_subnet.snet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.pubIP_worker[count.index].id
      }
    }

# Connette il gruppo di sicurezza con la NIC per i nodi master
resource "azurerm_network_interface_security_group_association" "master_isga" {
  count                     = var.master_count
  network_interface_id      = azurerm_network_interface.master_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Connette il gruppo di sicurezza con la NIC per i nodi worker
resource "azurerm_network_interface_security_group_association" "worker_isga" {
  count                     = var.worker_count
  network_interface_id      = azurerm_network_interface.worker_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id

  depends_on = [
    azurerm_network_interface.worker_nic,
    azurerm_network_security_group.nsg
  ]
}



resource "azurerm_public_ip" "lb_public_ip" {
  name                = "lb-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic" 
  sku                 = "Basic" 
}

resource "azurerm_lb" "main_lb" {
  name                = "main-load-balancer"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Basic"

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb_pool" {
  loadbalancer_id = azurerm_lb.main_lb.id
  name            = "bck_pool"
}

resource "azurerm_lb_nat_rule" "k8_nat_rule" {
  name                = "k8-nat-rule"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.main_lb.id
  frontend_ip_configuration_name = "frontend-ip-config"
  
  protocol = "Tcp" 
  frontend_port_start = 6443  
  frontend_port_end = 6443  
  backend_port  = 6443
  idle_timeout_in_minutes = 4

  enable_floating_ip = false
  backend_address_pool_id         = azurerm_lb_backend_address_pool.lb_pool.id
}

resource "azurerm_lb_nat_rule" "phpmyadm_nat_rule" {
  name                = "phpmyadm-nat-rule"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.main_lb.id
  frontend_ip_configuration_name = "frontend-ip-config"
  
  protocol = "Tcp" 
  frontend_port_start = 30880  
  frontend_port_end = 30880  
  backend_port  = 30880  
  idle_timeout_in_minutes = 4

  enable_floating_ip = false
  backend_address_pool_id         = azurerm_lb_backend_address_pool.lb_pool.id
}

resource "azurerm_lb_nat_rule" "nginx_nat_rule" {
  name                           = "nginx-nat-rule"
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.main_lb.id
  frontend_ip_configuration_name = "frontend-ip-config"
  
  protocol                      = "Tcp" 
  frontend_port_start           = 30080  
  frontend_port_end             = 30080  
  backend_port                  = 30080  
  idle_timeout_in_minutes       = 4

  enable_floating_ip            = false
   backend_address_pool_id      = azurerm_lb_backend_address_pool.lb_pool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "master_backend_pool_assoc" {
  count = var.master_count
  network_interface_id    = azurerm_network_interface.master_nic[count.index].id
  ip_configuration_name   = "ipconfig-master-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_pool.id
}
