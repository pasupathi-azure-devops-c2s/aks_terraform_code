variable "node_count" {
    type = number
    default = 4
    description = "Total number of nodes are working in the kubernetes cluster.."
  
}

variable "msi_id" {
    type = string
    default = null
    description = "Given MSI ID.."
  
}

