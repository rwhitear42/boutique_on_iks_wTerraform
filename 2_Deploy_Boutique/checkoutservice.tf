resource "kubernetes_deployment" "checkoutservice" {
  # wait_for_rollout = false

  metadata {
    name = "checkoutservice"
    namespace = var.deployment_id
  }

  spec {
    selector {
      match_labels = {
        app = "checkoutservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "checkoutservice"
        }
      }

      spec {
        service_account_name             = "default"
        termination_grace_period_seconds = 5
        container {
          image = "gcr.io/google-samples/microservices-demo/checkoutservice:v0.3.7"
          name  = "server"

          port {
            container_port = 5050
          }

          env {
            name  = "PORT"
            value = "5050"
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
            name  = "PRODUCT_CATALOG_SERVICE_ADDR"
            value = "productcatalogservice:3550"
          }

          env {
            name  = "SHIPPING_SERVICE_ADDR"
            value = "shippingservice:50051"
          }

          env {
            name  = "PAYMENT_SERVICE_ADDR"
            value = "paymentservice:50051"
          }

          env {
            name  = "EMAIL_SERVICE_ADDR"
            value = "emailservice:5000"
          }

          env {
            name  = "CURRENCY_SERVICE_ADDR"
            value = "currencyservice:7000"
          }

          env {
            name  = "CART_SERVICE_ADDR"
            value = "cartservice:7070"
          }

          env {
            name  = "DISABLE_STATS"
            value = "1"
          }

          readiness_probe {
            period_seconds = 5
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:5050"]
            }
          }

          liveness_probe {
            period_seconds = 5
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:5050"]
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

resource "kubernetes_service_v1" "checkoutservice" {
  metadata {
    name = "checkoutservice"
    namespace = var.deployment_id
  }
  spec {
    selector = {
      app = kubernetes_deployment.checkoutservice.metadata.0.name
    }

    port {
      name        = "grpc"
      port        = 5050
      target_port = 5050
    }

    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.deployment_id
  ]
}
