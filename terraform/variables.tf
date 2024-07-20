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
  description = "Hostname della macchina virtuale nodo Master"
  type        = string
  default     = "azure-k8-master"
}

variable "vm_master_user" {
  description = "Username della VM Master."
  type        = string
}

variable "vm_master_password" {
  description = "Password dell'utente VM master."
  type        = string
  sensitive   = true
}