variable "resource_group_name" {
  type        = string
}

variable "master_nic_ids" {
  type        = list(string)
}

variable "worker_nic_ids" {
  type        = list(string)
}

variable "location" {
  type        = string
}

variable "vm_size" {
  type        = string
}

variable "vm_name" {
  type        = string
}

variable "vm_admin_user" {
  type        = string
}

variable "vm_admin_password" {
  type        = string
}

variable "worker_count" {
  type        = number 
}

variable "master_count" {
  type        = number 
}