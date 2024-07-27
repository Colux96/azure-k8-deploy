variable "resource_group_name" {
  description = "Nome del gruppo di risorse"
  type        = string
  default     = "rg_azure_k8"
}

variable "location" {
  description = "La regione Azure dove effettuare il deploy delle risorse"
  type        = string
  default     = "West Europe"
}

variable "vnet_name" {
  description = "Nome della VNET"
  type        = string
  default     = "vnet_azure_k8"

}

variable "snet_name" {
  description = "Nome della Subnet"
  type        = string
  default     = "snet_azure_k8"
}

variable "pIP_name" {
  description = "Nome IP Publico"
  type        = string
  default     = "pubIP_azure_k8"
}

variable "nsg_name" {
  description = "Nome del Network Security Group"
  type        = string
  default     = "NSG_azure_k8"
}

variable "nic_name" {
  description = "Nome della NIC"
  type        = string
  default     = "master_NIC"
}

variable "vm_name" {
  description = "Hostname della macchina virtuale del nodo"
  type        = string
  default     = "azure-k8-node"
}

variable "vm_admin_user" {
  description = "Username della VM."
  type        = string
}

variable "vm_admin_password" {
  description = "Password dell'utente VM."
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "Tipo di VM da creare"
  type        = string
  default     = "Standard_B1s"
}

variable "vm_total_count" {
  description = "Numero totale di macchine virtuali da creare"
  type        = number
  default     = 3
}

variable "master_count" {
  description = "Numero di macchine virtuali, tipo di nodo MASTER, da creare"
  type        = number
  default     = 1
}

variable "worker_count" {
  description = "Numero di macchine virtuali, tipo di nodo WORKER, da creare"
  type        = number
  default     = 2
}

variable "namespace_name" {
  description = "Nome del namespace da creare sul cluster"
  type        = string
  default     = "namespace_test"
}