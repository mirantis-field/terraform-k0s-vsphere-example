locals {
  start_ip = split("-", var.ip_range)[0]
  end_ip   = split("-", var.ip_range)[1]

  start_parts = split(".", local.start_ip)
  end_parts   = split(".", local.end_ip)
  start_last_octet = tonumber(local.start_parts[3])
}

resource "vsphere_virtual_machine" "vm" {
    count = var.quantity

    name = "${var.name_prefix}${count.index}"
    resource_pool_id = var.resource_pool_id
    #datastore_cluster_id = var.datastore_cluster_id
    datastore_id = var.datastore_id

    folder = var.folder

    guest_id = var.template_vm.guest_id

    network_interface {
        network_id = var.network_id
    }

    num_cpus         = var.cpu_count

    memory           = var.memory_count

    enable_disk_uuid = true # NB the VM must have disk.EnableUUID=1 for, e.g., k8s persistent storage.

    disk {
        label            = "${var.name_prefix}${count.index}"
        size             = var.disk_size
        thin_provisioned = var.template_vm.disks.0.thin_provisioned
    }

    clone {
        template_uuid = var.template_vm.id

#        customize {
#            network_interface {
#              ipv4_address = format("${local.start_parts[0]}.${local.start_parts[1]}.${local.start_parts[2]}.%s", sum([local.start_last_octet, count.index]))
#              ipv4_netmask = var.ip_prefix 
#            }
#
#            # Hmm, the linux and windows options might make it tricky to have
#            # a single module for handling virtual machines.
#            linux_options {
#                host_name = "${var.name_prefix}${count.index}"
#                domain    = "test.internal"
#            }
#            ipv4_gateway = var.network_gateway
#        }
    }

#you need to enable vApp for the VM and add hostname and user-data fields in vSphere UI to be able to use the block below
#vapp also requires the clone block above
#    vapp {
#        properties = {
#            hostname = "${var.name_prefix}${count.index}"
#            user-data = base64encode(file("${path.module}/cloudinit/kickstart.yaml"))
#        }
#    }

#limited use without vapp
    extra_config = {
       "guestinfo.userdata"          = base64encode(templatefile("${path.module}/cloudinit/userdata.yaml", { k0s_lb_ip = var.k0s_lb_ip, ssh_key = var.ssh_key, hostname = "${var.name_prefix}${count.index}"}))
       "guestinfo.userdata.encoding" = "base64"
       "guestinfo.metadata"          = base64encode(templatefile("${path.module}/cloudinit/metadata.yaml", { ip_addr = format("${local.start_parts[0]}.${local.start_parts[1]}.${local.start_parts[2]}.%s", sum([local.start_last_octet, count.index])), gateway_addr = var.network_gateway, hostname = "${var.name_prefix}${count.index}"}))
       "guestinfo.metadata.encoding" = "base64"
    }
}
