resource "kubernetes_deployment" "currencyservice" {
  # wait_for_rollout = false

  metadata {
    name = "currencyservice"
    namespace = var.deployment_id
  }

  spec {
    selector {
      match_labels = {
        app = "currencyservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "currencyservice"
        }
      }

      spec {
        service_account_name             = "default"
        termination_grace_period_seconds = 5
        container {
          image = "gcr.io/google-samples/microservices-demo/currencyservice:v0.3.7"
          name  = "server"

          port {
            name           = "grpc"
            container_port = 7000
          }

          env {
            name  = "PORT"
            value = "7000"
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
            name  = "DISABLE_DEBUGGER"
            value = "1"
          }

          readiness_probe {
            period_seconds = 5
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:7000"]
            }
          }

          liveness_probe {
            period_seconds = 5
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:7000"]
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

resource "kubernetes_service_v1" "currencyservice" {
  metadata {
    name = "currencyservice"
    namespace = var.deployment_id
  }
  spec {
    selector = {
      app = kubernetes_deployment.currencyservice.metadata.0.name
    }

    port {
      name        = "grpc"
      port        = 7000
      target_port = 7000
    }

    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.deployment_id
  ]
}
