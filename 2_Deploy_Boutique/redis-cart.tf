resource "kubernetes_deployment" "redis-cart" {
  metadata {
    name = "redis-cart"
    namespace = var.deployment_id
  }

  spec {
    selector {
      match_labels = {
        app = "redis-cart"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis-cart"
        }
      }

      spec {
        container {
          image = "redis:alpine"
          name  = "redis"

          port {
            container_port = 6379
          }

          readiness_probe {
            period_seconds = 5
            tcp_socket {
              port = 6379
            }
          }

          liveness_probe {
            period_seconds = 5
            tcp_socket {
              port = 6379
            }
          }

          volume_mount {
            mount_path = "/data"
            name       = "redis-data"
          }

          resources {
            limits = {
              cpu    = "125m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "70m"
              memory = "200Mi"
            }
          }
        }
        volume {
          name = "redis-data"
          # empty_dir = {
          #   medium = ""
          # }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.deployment_id
  ]
}

resource "kubernetes_service_v1" "redis-cart" {
  metadata {
    name = "redis-cart"
    namespace = var.deployment_id
  }
  spec {
    selector = {
      app = "redis-cart"
    }

    port {
      name        = "redis"
      port        = 6379
      target_port = 6379
    }

    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.deployment_id
  ]
}
