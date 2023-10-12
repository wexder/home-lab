output "talos_cluster_kubeconfig" {
  value = data.talos_cluster_kubeconfig.this
}

output "talos_config" {
  value = data.talos_client_configuration.this
}
