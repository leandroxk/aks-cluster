variable "rg_location" {}
variable "rg_name" {}
variable "noderg_name" {}
variable "cluster_name" {}
variable "environment" { default = "Development" }

# Network Security
resource "azurerm_route_table" "current" {
  name                = "aks-rt-${var.cluster_name}"
  location            = var.rg_location
  resource_group_name = var.rg_name

  route {
    name                   = "default"
    address_prefix         = "10.100.0.0/14"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.1"
  }
}

# Network
resource "azurerm_virtual_network" "current" {
  name                = "aks-vnet-${var.cluster_name}"
  location            = var.rg_location
  resource_group_name = var.rg_name
  address_space       = ["10.10.0.0/16"]
  dns_servers         = ["1.1.1.1", "8.8.8.8"]

  tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet" "internal" {
  name                  = "internal"
  resource_group_name   = var.rg_name
  virtual_network_name  = azurerm_virtual_network.current.name
  address_prefix        = "10.10.0.0/24"
}

# Security Group
resource "azurerm_network_security_group" "current" {
  name                = "aks-secgroup-${var.cluster_name}"
  location            = var.rg_location
  resource_group_name = var.rg_name
}

# Network x Route Table
resource "azurerm_subnet_route_table_association" "current" {
  subnet_id      = azurerm_subnet.internal.id
  route_table_id = azurerm_route_table.current.id
}

# Network x Security Group
resource "azurerm_subnet_network_security_group_association" "current" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.current.id
}

# Public IP
resource "azurerm_public_ip" "aks-public-ip" {
  name = "aks-public-ip-${var.cluster_name}"
  count = 1
  resource_group_name = var.noderg_name
  location = var.rg_location
  allocation_method = "Static"
}

output "subnet_id" {
  value = azurerm_subnet.internal.id
}

output "public_ip" {
  value = length(azurerm_public_ip.aks-public-ip.*) == 1 ? azurerm_public_ip.aks-public-ip[0].ip_address : null
}