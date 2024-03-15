variable "quantity" {
    description = "Number of VMs to create"
}

variable "name_prefix" {
    description = "The name of the VMs will be this plus a counter value"
}

variable "resource_pool_id" {
    description = "ID of the resource pool to create the VMs in"
}

variable "datastore_id" {
    description = "ID of the datastore cluster to create the VMs in"
}

variable "folder" {
    description = "Subfolder in the datacenter at which to create the VMs"
}

variable "network_id" {
    description = "ID of the network to attach the VMs to"
}

variable "template_vm" {
    description = "The template VM which will be cloned as the base for the new VMs"
}

variable "disk_size" {
    description = "Size of the disk drive for the VMs"
}

variable "cpu_count" {
  description = "Number of CPUs in manager and worker VMs"
  default     = 4
}

variable "memory_count" {
  description = "Amount of memory in manager and worker VMs"
  default     = 4096
}

variable "ip_range" {
  description = "IP range to be assigned to VMs"
  type        = string
  default     = ""
}

variable "k0s_lb_ip" {
  description = "IP address to be assigned to k0s API LB"
  type        = string
  default     = ""
}

variable "network_gateway" {
  description = "Gateway IP address to be used as default gateway for VMs"
  type        = string
  default     = ""
}

variable "ip_prefix" {
  description = "IP prefix to be used for IP addresses"
  default     = 24
}

variable "ssh_key" {
  description = "Public SSH key to be added to authorized_keys"
  type        = string
  default     = ""
}

variable "nameserver" {
  description = "DNS to be added to the VM network configuration"
  type        = string
  default     = ""
}
