variable "vsphere_server" {
  description = "URL of vSphere server"
}

variable "vsphere_user" {
  description = "Username for connecting to vSphere"
}

variable "vsphere_password" {
  description = "Password for vSphere connection"
}

variable "datacenter" {
  default = ""
}

variable "resource_pool" {
}

variable "folder" {
  default = ""
}

variable "datastore" {
}

variable "network" {
}

variable "controller_vm_template" {
  description = "VM to use as a template for controllers"
}

variable "worker_vm_template" {
  description = "VM to use as a template for workers"
}

variable "ssh_private_key_file" {
  description = "Private key for SSH connections to created virtual machines"
}
variable "ssh_public_key_file" {
  description = "Public key for SSH connections to created virtual machines"
}

variable "k0s_version" {
  description = "Desired k0s version"
  default     = ""
}

variable "quantity_controllers" {
  description = "Number of k0s controller VMs to create"
  default     = 3
}

variable "quantity_workers" {
  description = "Number of k0s worker VMs to create"
  default     = 3
}

variable "cpu_count" {
  description = "Number of CPUs in contoller and worker VMs"
  default     = 4
}

variable "memory_count" {
  description = "Amount of memory in controller and worker VMs"
  default     = 4096
}

variable "ip_range_controllers" {
  description = "IP addresses to be assigned to controller VMs"
  type        = string
  default     = ""
}

variable "ip_range_workers" {
  description = "IP addresses to be assigned to worker VMs"
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

variable "nameserver" {
  description = "DNS to be added to the VM network configuration"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of the cluster (will be used as prefix for cluster nodes)"
  default     = "k0s-cluster"
}
