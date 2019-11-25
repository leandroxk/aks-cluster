provider "azurerm" {
    version = "~> 1.36.1"
}

provider "tls" {
  version = "~> 2.1"
}

resource "azurerm_resource_group" "main" {
    name     = var.resource_group_name
    location = var.resource_group_location

    tags = {
        environment = var.environment
    }
}

module "azure_network" {
    source       = "./modules/network"
    rg_location  = azurerm_resource_group.main.location
    rg_name      = azurerm_resource_group.main.name
    environment  = var.environment
    cluster_name = var.cluster_name
}

# Create a service principal with password valid for 2 years
module "service_principal" {
  source             = "./modules/service-principal"
  name               = var.cluster_name
  years_to_pw_expire = 2
}

#tls_private_key.current.public_key_openssh
resource "tls_private_key" "current" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

# cluster k8s
resource "azurerm_kubernetes_cluster" "main" {
    name                = var.cluster_name
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    dns_prefix          = var.dns_prefix
    node_resource_group = "aks-noderg-${var.cluster_name}" #  https://github.com/Azure/AKS/issues/3

    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
            key_data = tls_private_key.current.public_key_openssh
        }
    }

    agent_pool_profile {
        name            = "minimal"
        count           = 1
        vm_size         = "Standard_B2s"
        os_type         = "Linux"
        os_disk_size_gb = 30
        vnet_subnet_id  = module.azure_network.subnet_id
    }

    service_principal {
        client_id     = module.service_principal.client_id
        client_secret = module.service_principal.client_secret
    }

    tags = {
        Environment = var.environment
    }

    network_profile {
        network_plugin = "azure"
    }
}

data "azurerm_subscription" "current" {}

output "current_subscription_display_name" {
    value = data.azurerm_subscription.current.display_name
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.main.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.main.kube_config_raw
}

output "subnets" {
  value = module.azure_network.subnet_id
}