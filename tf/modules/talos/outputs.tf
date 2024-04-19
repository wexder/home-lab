output "talos_cluster_kubeconfig" {
  value     = module.talos_nodes.talos_cluster_kubeconfig
  sensitive = true
}

output "talos_config" {
  value     = module.talos_nodes.talos_config
  sensitive = true
}
