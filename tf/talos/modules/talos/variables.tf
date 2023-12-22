variable "cluster_endpoint" {
  description = "Cluster endpoint"
  type        = string
}

variable "node_ips" {
  description = "Cluster nodes"
  type        = list(string)
}

variable "nodes" {
  description = "Nodes configuration"
  type = map(
    object({
      ip     = string
      vip    = string
      cores  = number
      memory = number
    })
  )
}
