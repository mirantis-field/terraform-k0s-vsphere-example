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
            name = "k0s-cilium-cluster"
          }
          spec = {
            api = {
              address = var.external_ip_address
              externalAddress = var.external_ip_address
              k0sApiPort = 9443
              port = 6443
              sans = [
                var.external_ip_address
              ]
              #tunneledNetworkingMode = false
            }
            controllerManager = {}
            installConfig = {
              users = {
                etcdUser = "etcd"
                kineUser = "kube-apiserver"
                konnectivityUser = "konnectivity-server"
                kubeAPIserverUser = "kube-apiserver"
                kubeSchedulerUser = "kube-scheduler"
              }
            }
            network = {
              kubeProxy = {
                disabled = false
                mode = "ipvs"
                ipvs = {
                  strictARP = true
                }
              }
# Node local balancing when you have multiple controllers, but no external reverse proxy
#             nodeLocalLoadBalancing = {
#               enabled = true
#               type = EnvoyProxy
#             }
              podCIDR = "10.244.0.0/16"
              #custom means that podCIDR is ignored. As cilium is deployed as helm, the default Cilium podCIDR is used: 10.0.0.0/8
              provider = "custom"
              serviceCIDR = "10.96.0.0/12"
            }
            storage = {
              type = "etcd"
            }
            telemetry = {
              enabled = true
            }
            extensions = {
              helm = {
                repositories = [
                  {
                    name = "cilium"
                    url = "https://helm.cilium.io/"
                  },
                  {
                    name = "metallb"
                    url = "https://metallb.github.io/metallb"
                  },
                  {
                    name = "traefik"
                    url = "https://traefik.github.io/charts"
                  },
                ]
                charts = [
                  {
                    name = "a-cilium"
                    chartname = "cilium/cilium"
                    namespace = "kube-system"
                    version = "1.13.1"
                  },
                  {
                    name = "metallb"
                    chartname = "metallb/metallb"
                    namespace = "metallb"
                  },
                  {
                    name = "traefik"
                    chartname = "traefik/traefik"
                    namespace = "default"
                    version = "20.5.3"
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

