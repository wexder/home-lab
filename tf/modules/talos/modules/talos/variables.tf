variable "cluster_endpoint" {
  description = "Cluster endpoint"
  type        = string
}

variable "nodes" {
  description = "Nodes configuration"
  type = map(
    object({
      ip           = string
      vip          = string
      target_node  = string
      cores        = number
      memory       = number
      machine_type = string
    })
  )
}
