variable "public_ip" {}
variable "host" {}
variable "client_certificate" {}
variable "client_key" {}
variable "cluster_ca_certificate" {}

provider "kubernetes" {
  host = var.host

  client_certificate     = base64decode(var.client_certificate)
  client_key             = base64decode(var.client_key)
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

# Ingress using public IP
resource "kubernetes_service" "nginx_ingress_service" {
  metadata {
    name = "ingress-nginx"
    namespace = "default"

    labels = {
      "app.kubernetes.io/name": "ingress-nginx"
      "app.kubernetes.io/part-of": "ingress-nginx"
    }
  }

  spec {
    type = "LoadBalancer"
    external_traffic_policy = "Local"

    selector = {
      "app.kubernetes.io/name": "ingress-nginx"
      "app.kubernetes.io/part-of": "ingress-nginx"
    }

    port {
      name = "http"
      port = 80
      target_port = "http"
    }

    port {
      name = "https"
      port = 443
      target_port = "https"
    }

    load_balancer_ip = var.public_ip
  }
}