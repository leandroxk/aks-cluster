variable "resource_group_name" { 
    description = "Name of the resource group."
}

variable "node_resource_group_name" { 
    description = "Name of the cluster resource group."
}

variable "location" { 
    description = "Location of the cluster."
    default = "centralus"
}
variable "cluster_name" { 
    description = "Name of the cluster."
}
variable "dns_prefix" {
    type = string
}
variable "environment" { 
    type = string
    default = "Development"
}



