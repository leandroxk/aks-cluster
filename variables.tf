variable "resource_group_name" { 
    type = string
}
variable "resource_group_location" { 
    type = string
    default = "centralus"
}
variable "cluster_name" { 
    type = string
}
variable "dns_prefix" {
    type = string
}
variable "environment" { 
    type = string
    default = "Development"
}
