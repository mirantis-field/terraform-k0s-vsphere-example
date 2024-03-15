locals {
  controllers = [
    for host in module.controllers.machines : {
      ssh = {
            address = host.default_ip_address
            user    = "ubuntu"
            keyPath = var.ssh_private_key_file
          }
          installFlags = [
            "--enable-cloud-provider",
            "--kubelet-extra-args=\"--cloud-provider=external\""
          ]
          role = "controller+worker"
      }
  ]

  workers = [
    for host in module.workers.machines : {
      ssh = {
            address = host.default_ip_address
            user    = "ubuntu"
            keyPath = var.ssh_private_key_file
          }
          installFlags = [
            "--enable-cloud-provider",
            "--kubelet-extra-args=\"--cloud-provider=external\""
          ]
          role = "worker"
      }
  ]

  k0s_tmpl = {
    apiVersion = "k0sctl.k0sproject.io/v1beta1"
    kind       = "Cluster"
    spec = {
      hosts = concat(local.controllers, local.workers)
      k0s = {
        version = var.k0s_version
        dynamicConfig = false
        config = {
          apiVersion = "k0s.k0sproject.io/v1beta1"
          kind = "ClusterConfig"
          metadata = {
            name = "${var.cluster_name}"
          }
          spec = {
            api = {
              sans = [
                var.k0s_lb_ip
              ]
            }
            network = {
             nodeLocalLoadBalancing = {
               enabled = true
               type = "EnvoyProxy"
             }
              provider = "calico"
            }
            extensions = {
              helm = {
                repositories = [
                  {
                    name = "vsphere-cpi"
                    url = "https://kubernetes.github.io/cloud-provider-vsphere"
                  },
                ]
                charts = [
                  {
                    name = "vsphere-cpi"
                    chartname = "vsphere-cpi/vsphere-cpi"
                    namespace = "kube-system"
                    version = "1.29.0"
                    values = <<-EOT
                      config:
                        enabled: true
                        vcenter: ${var.vsphere_server}
                        username: ${var.vsphere_user}
                        password: ${var.vsphere_password}
                        datacenter: ${var.datacenter}
                        region: ""
                        zone: ""
                        secret:
                          name: cloud-provider-vsphere-credentials
                    EOT
                  },
                ]
              }
            }
          }
        }
      }
    }
  }
}

output "k0s_cluster" {
  value = replace(yamlencode(local.k0s_tmpl), "/((?:^|\n)[\\s-]*)\"([\\w-]+)\":/", "$1$2:")
}

