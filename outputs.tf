locals {
  managers = [
    for host in module.managers.machines : {
      ssh = {
            address = host.default_ip_address
            user    = "ubuntu"
            keyPath = var.ssh_private_key_file
          }
          #installFlags = [
          #  "--enable-cloud-provider",
          #  "--kubelet-extra-args=\"--cloud-provider=external\""
          #]
          role = "controller+worker"
          noTaints = true
      }
  ]

  workers = [
    for host in module.workers.machines : {
      ssh = {
            address = host.default_ip_address
            user    = "ubuntu"
            keyPath = var.ssh_private_key_file
          }
          #installFlags = [
          #  "--enable-cloud-provider",
          #  "--kubelet-extra-args=\"--cloud-provider=external\""
          #]
          role = "worker"
      }
  ]

  k0s_tmpl = {
    apiVersion = "k0sctl.k0sproject.io/v1beta1"
    kind       = "Cluster"
    spec = {
      hosts = concat(local.managers, local.workers)
      k0s = {
        version = var.k0s_version
        dynamicConfig = false
        config = {
          apiVersion = "k0s.k0sproject.io/v1beta1"
          kind = "ClusterConfig"
          metadata = {
            name = "k0s-cluster"
          }
          spec = {
            api = {
              sans = [
                var.external_ip_address
              ]
              #tunneledNetworkingMode = false
            }
            network = {
# Node local balancing when you have multiple controllers, but no external reverse proxy
             nodeLocalLoadBalancing = {
               enabled = true
               type = "EnvoyProxy"
             }
              #custom means that podCIDR is ignored. As cilium is deployed as helm, the default Cilium podCIDR is used: 10.0.0.0/8
              provider = "calico"
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

