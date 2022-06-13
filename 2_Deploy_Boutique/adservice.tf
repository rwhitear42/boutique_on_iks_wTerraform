resource "kubernetes_deployment" "adservice" {
  wait_for_rollout = false

  metadata {
    name = "adservice"
    namespace = var.deployment_id
  }

  spec {
    selector {
      match_labels = {
        app = "adservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "adservice"
        }
      }

      spec {
        service_account_name             = "default"
        termination_grace_period_seconds = 5
        container {
          image = "gcr.io/google-samples/microservices-demo/adservice:v0.3.7"
          name  = "server"

          port {
            # name           = "grpc"
            container_port = 9555
          }

          env {
            name  = "PORT"
            value = "9555"
          }

          env {
            name  = "DISABLE_TRACING"
            value = "1"
          }

          env {
            name  = "DISABLE_STATS"
            value = "1"
          }

          readiness_probe {
            initial_delay_seconds = 20
            period_seconds = 15
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:9555"]
            }
          }

          liveness_probe {
            initial_delay_seconds = 20
            period_seconds = 15
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:9555"]
            }
          }

          resources {
            limits = {
              cpu    = "300m"
              memory = "300Mi"
            }
            requests = {
              cpu    = "200m"
              memory = "180Mi"
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

resource "kubernetes_service_v1" "adservice" {
  metadata {
    name = "adservice"
    namespace = var.deployment_id
  }
  spec {
    selector = {
      app = "adservice"
    }

    port {
      name        = "grpc"
      port        = 9555
      target_port = 9555
    }

    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.deployment_id
  ]
}
