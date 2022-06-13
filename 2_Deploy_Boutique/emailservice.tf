resource "kubernetes_deployment" "emailservice" {
  # wait_for_rollout = false

  metadata {
    name = "emailservice"
    namespace = var.deployment_id
  }

  spec {
    selector {
      match_labels = {
        app = "emailservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "emailservice"
        }
      }

      spec {
        service_account_name             = "default"
        termination_grace_period_seconds = 5
        container {
          image = "gcr.io/google-samples/microservices-demo/emailservice:v0.3.7"
          name  = "server"

          port {
            container_port = 8080
          }

          env {
            name  = "PORT"
            value = "8080"
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
              command = ["/bin/grpc_health_probe", "-addr=:8080"]
            }
          }

          liveness_probe {
            period_seconds = 5
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:8080"]
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

resource "kubernetes_service_v1" "emailservice" {
  metadata {
    name = "emailservice"
    namespace = var.deployment_id
  }
  spec {
    selector = {
      app = kubernetes_deployment.emailservice.metadata.0.name
    }

    port {
      name        = "grpc"
      port        = 5000
      target_port = 8080
    }

    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.deployment_id
  ]
}
