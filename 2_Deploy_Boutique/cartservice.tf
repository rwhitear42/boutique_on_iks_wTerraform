resource "kubernetes_deployment" "cartservice" {
  wait_for_rollout = false

  metadata {
    name = "cartservice"
    namespace = var.deployment_id
  }

  spec {
    selector {
      match_labels = {
        app = "cartservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "cartservice"
        }
      }

      spec {
        service_account_name             = "default"
        termination_grace_period_seconds = 5
        container {
          image = "gcr.io/google-samples/microservices-demo/cartservice:v0.3.7"
          name  = "server"

          port {
            container_port = 7070
          }

          env {
            name  = "REDIS_ADDR"
            value = "redis-cart:6379"
          }

          readiness_probe {
            period_seconds = 5
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:7070", "-rpc-timeout=5s"]
            }
          }

          liveness_probe {
            period_seconds = 5
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:7070", "-rpc-timeout=5s"]
            }
          }

          resources {
            limits = {
              cpu    = "300m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "200m"
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

resource "kubernetes_service_v1" "cartservice" {
  metadata {
    name = "cartservice"
    namespace = var.deployment_id
  }
  spec {
    selector = {
      app = kubernetes_deployment.cartservice.metadata.0.name
    }

    port {
      name        = "grpc"
      port        = 7070
      target_port = 7070
    }

    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_deployment.cartservice,
    kubernetes_namespace.deployment_id
  ]
}
