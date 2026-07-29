locals {
  labels = {
    "app.kubernetes.io/name"       = var.name
    "app.kubernetes.io/component"  = "postgrest"
    "app.kubernetes.io/managed-by" = "terraform"
  }
}

resource "kubernetes_deployment_v1" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = local.labels
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false

        container {
          name  = "postgrest"
          image = var.image

          image_pull_policy = "Always"
          args              = ["/etc/postgrest/postgrest.conf"]

          port {
            container_port = 3000
            name           = "http"
          }

          volume_mount {
            name       = "configuration"
            mount_path = "/etc/postgrest"
            read_only  = true
          }

          liveness_probe {
            tcp_socket {
              port = "http"
            }
          }

          readiness_probe {
            tcp_socket {
              port = "http"
            }
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true

            capabilities {
              drop = ["ALL"]
            }
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }

        volume {
          name = "configuration"

          secret {
            secret_name = var.configuration_secret_name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    type     = "ClusterIP"
    selector = local.labels

    port {
      name        = "http"
      port        = 3000
      target_port = "http"
    }
  }
}
