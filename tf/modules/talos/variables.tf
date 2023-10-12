variable "cluster_endpoint" {
  description = "Cluster endpoint"
  type        = string
}

variable "nodes" {
  description = "Nodes configuration"
  type = map(
    object({
      ip     = string
      cores  = number
      memory = number
    })
  )
}
