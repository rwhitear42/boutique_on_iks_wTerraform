resource "kubernetes_deployment" "recommendationservice" {
  # wait_for_rollout = false

  metadata {
    name = "recommendationservice"
    namespace = var.deployment_id
  }

  spec {
    selector {
      match_labels = {
        app = "recommendationservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "recommendationservice"
        }
      }

      spec {
        service_account_name             = "default"
        termination_grace_period_seconds = 5
        container {
          image = "gcr.io/google-samples/microservices-demo/recommendationservice:v0.3.7"
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
            name  = "DISABLE_DEBUGGER"
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
              memory = "450Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "220Mi"
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

resource "kubernetes_service_v1" "recommendationservice" {
  metadata {
    name = "recommendationservice"
    namespace = var.deployment_id
  }
  spec {
    selector = {
      app = kubernetes_deployment.recommendationservice.metadata.0.name
    }

    port {
      name        = "grpc"
      port        = 8080
      target_port = 8080
    }

    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.deployment_id
  ]
}
