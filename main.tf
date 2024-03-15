terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 1.15.0"
    }
  }
}

provider "vsphere" {
  vsphere_server = var.vsphere_server
  user           = var.vsphere_user
  password       = var.vsphere_password

  # Enable this if your vSphere server has a self-signed certificate
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_resource_pool" "resource_pool" {
  name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "controller_vm_template" {
  name          = var.controller_vm_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "worker_vm_template" {
  name          = var.worker_vm_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

module "managers" {
  source               = "./modules/virtual_machine"
  quantity             = var.quantity_managers
  name_prefix          = "${var.cluster_name}-001-ctr0"
  resource_pool_id     = data.vsphere_resource_pool.resource_pool.id
  datastore_id         = data.vsphere_datastore.datastore.id
  folder               = var.folder
  network_id           = data.vsphere_network.network.id
  template_vm          = data.vsphere_virtual_machine.controller_vm_template
  disk_size            = 100
  ip_range             = var.ip_range_managers
  network_gateway      = var.network_gateway
  k0s_lb_ip            = var.k0s_lb_ip
  ssh_key              = file(var.ssh_public_key_file)
  nameserver           = var.nameserver
}

module "workers" {
  source               = "./modules/virtual_machine"
  quantity             = var.quantity_workers
  name_prefix          = "${var.cluster_name}-001-wrk0"
  resource_pool_id     = data.vsphere_resource_pool.resource_pool.id
  datastore_id         = data.vsphere_datastore.datastore.id
  folder               = var.folder
  network_id           = data.vsphere_network.network.id
  template_vm          = data.vsphere_virtual_machine.worker_vm_template
  disk_size            = 100
  ip_range             = var.ip_range_workers
  network_gateway      = var.network_gateway
  ssh_key              = file(var.ssh_public_key_file)
  nameserver           = var.nameserver
}
