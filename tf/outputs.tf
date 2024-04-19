output "talos_cluster_kubeconfig" {
  value     = module.talos.talos_cluster_kubeconfig
  sensitive = true
}

output "talos_config" {
  value     = module.talos.talos_config
  sensitive = true
}
