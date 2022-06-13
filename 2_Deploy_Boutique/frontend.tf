resource "kubernetes_deployment" "frontend" {
  # wait_for_rollout = false

  metadata {
    name = "frontend"
    namespace = var.deployment_id
  }

  spec {
    selector {
      match_labels = {
        app = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "frontend"
        }
        annotations = {
          "sidecar.istio.io/rewriteAppHTTPProbers" = "true"
        }
      }

      spec {
        service_account_name = "default"
        container {
          image = "gcr.io/google-samples/microservices-demo/frontend:v0.3.7"
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

          env {
            name  = "PRODUCT_CATALOG_SERVICE_ADDR"
            value = "productcatalogservice:3550"
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
            name  = "RECOMMENDATION_SERVICE_ADDR"
            value = "recommendationservice:8080"
          }

          env {
            name  = "SHIPPING_SERVICE_ADDR"
            value = "shippingservice:50051"
          }

          env {
            name  = "CHECKOUT_SERVICE_ADDR"
            value = "checkoutservice:5050"
          }

          env {
            name  = "AD_SERVICE_ADDR"
            value = "adservice:9555"
          }

          readiness_probe {
            initial_delay_seconds = 10
            http_get {
              path = "/_healthz"
              port = 8080
              http_header {
                name  = "Cookie"
                value = "shop_session-id=x-readiness-probe"
              }
            }
          }

          liveness_probe {
            initial_delay_seconds = 10
            http_get {
              path = "/_healthz"
              port = 8080
              http_header {
                name  = "Cookie"
                value = "shop_session-id=x-readiness-probe"
              }
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

resource "kubernetes_service_v1" "frontend" {
  metadata {
    name = "frontend"
    namespace = var.deployment_id
  }
  spec {
    selector = {
      app = kubernetes_deployment.frontend.metadata.0.name
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8080
    }

    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.deployment_id
  ]
}

resource "kubernetes_service_v1" "frontend_external" {
  metadata {
    name = "frontend-external"
    namespace = var.deployment_id
  }
  spec {
    selector = {
      app = kubernetes_deployment.frontend.metadata.0.name
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8080
    }

    type = "NodePort"
  }

  depends_on = [
    kubernetes_namespace.deployment_id
  ]
}
