resource "kubernetes_namespace" "deployment_id" {
  metadata {
    name = var.deployment_id
  }
}