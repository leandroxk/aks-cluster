variable "kubeconfig_path" {}

resource "null_resource" "ingress" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/yaml/controller.yaml --kubeconfig ${var.kubeconfig_path}"
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/yaml/service.yaml --kubeconfig ${var.kubeconfig_path}"
  }

  provisioner "local-exec" {
    when = destroy
    command = "kubectl delete -f ${path.module}/yaml/service.yaml --kubeconfig ${var.kubeconfig_path}"
  }
  provisioner "local-exec" {
    when = destroy
    command = "kubectl delete -f ${path.module}/yaml/controller.yaml --kubeconfig ${var.kubeconfig_path}"
  }
}
