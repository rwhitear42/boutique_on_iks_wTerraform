resource "kubernetes_deployment" "shippingservice" {
  # wait_for_rollout = false

  metadata {
    name = "shippingservice"
    namespace = var.deployment_id
  }

  spec {
    selector {
      match_labels = {
        app = "shippingservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "shippingservice"
        }
      }

      spec {
        service_account_name             = "default"
        termination_grace_period_seconds = 5
        container {
          image = "gcr.io/google-samples/microservices-demo/shippingservice:v0.3.7"
          name  = "server"

          port {
            name           = "grpc"
            container_port = 50051
          }

          env {
            name  = "PORT"
            value = "50051"
          }

          env {
            name  = "DISABLE_TRACING"
            value = "1"
          }

          env {
            name  = "DISABLE_PROFILER"
            value = "1"
          }

          env {
            name  = "DISABLE_STATS"
            value = "1"
          }

          readiness_probe {
            period_seconds = 5
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:50051"]
            }
          }

          liveness_probe {
            period_seconds = 5
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:50051"]
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

resource "kubernetes_service_v1" "shippingservice" {
  metadata {
    name = "shippingservice"
    namespace = var.deployment_id
  }
  spec {
    selector = {
      app = kubernetes_deployment.shippingservice.metadata.0.name
    }

    port {
      name        = "grpc"
      port        = 50051
      target_port = 50051
    }

    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.deployment_id
  ]
}
