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
}

# Crea un IP publico per il nodo master
resource "azurerm_public_ip" "pubIP_master" {
  count               = var.master_count
  name                = "public-ip-master-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

# Crea Network Security Group e regola SSH in ingresso
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

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
}

# Crea una NIC per nodo di tipo master
resource "azurerm_network_interface" "master_nic" {
  count               = var.master_count
  name                = "${var.nic_name}-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.nic_name}-${count.index}"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pubIP_master[count.index].id

  }
}

# Crea una NIC per nodo di tipo worker
resource "azurerm_network_interface" "nic" {
      count                = var.worker_count
      name                 = "${var.nic_name}-${count.index}"
      location            = var.location
      resource_group_name = var.resource_group_name

      ip_configuration {
        name                          = "${var.nic_name}-${count.index}"
        subnet_id                     = azurerm_subnet.snet.id
        private_ip_address_allocation = "Dynamic"
      }
    }

# Connette il gruppo di sicurezza Master con la NIC
resource "azurerm_network_interface_security_group_association" "master_isga" {
  count                     = var.master_count
  network_interface_id      = azurerm_network_interface.master_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Connette il gruppo di sicurezza Worker con la NIC
resource "azurerm_network_interface_security_group_association" "worker_isga" {
  count                     = var.worker_count
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}