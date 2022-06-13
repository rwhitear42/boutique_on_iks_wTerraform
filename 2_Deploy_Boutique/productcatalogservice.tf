resource "kubernetes_deployment" "productcatalogservice" {
  # wait_for_rollout = false

  metadata {
    name = "productcatalogservice"
    namespace = var.deployment_id
  }

  spec {
    selector {
      match_labels = {
        app = "productcatalogservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "productcatalogservice"
        }
      }

      spec {
        service_account_name             = "default"
        termination_grace_period_seconds = 5
        container {
          image = "gcr.io/google-samples/microservices-demo/productcatalogservice:v0.3.7"
          name  = "server"

          port {
            container_port = 3550
          }

          env {
            name  = "PORT"
            value = "3550"
          }

          env {
            name  = "DISABLE_STATS"
            value = "1"
          }

          env {
            name  = "DISABLE_TRACING"
            value = "1"
          }

          env {
            name  = "DISABLE_PROFILER"
            value = "1"
          }

          readiness_probe {
            period_seconds = 5
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:3550"]
            }
          }

          liveness_probe {
            period_seconds = 5
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:3550"]
            }
          }

          resources {
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.deployment_id
  ]
}

resource "kubernetes_service_v1" "productcatalogservice" {
  metadata {
    name = "productcatalogservice"
    namespace = var.deployment_id
  }
  spec {
    selector = {
      app = kubernetes_deployment.productcatalogservice.metadata.0.name
    }

    port {
      name        = "grpc"
      port        = 3550
      target_port = 3550
    }

    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.deployment_id
  ]
}
