locals {
  labels = {
    "app.kubernetes.io/name"       = var.name
    "app.kubernetes.io/component"  = "metabase"
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
        security_context {
          fs_group        = 2000
          run_as_user     = 2000
          run_as_group    = 2000
          run_as_non_root = true
        }
        termination_grace_period_seconds = 120

        container {
          name  = "metabase"
          image = var.image

          image_pull_policy = "Always"
          working_dir       = "/tmp"

          port {
            container_port = 3000
            name           = "http"
          }

          env {
            name  = "MB_DB_TYPE"
            value = "postgres"
          }

          env {
            name  = "MB_DB_CONNECTION_URI_FILE"
            value = "/etc/metabase/database/connection-uri"
          }

          volume_mount {
            name       = "runtime"
            mount_path = "/tmp"
          }

          volume_mount {
            name       = "application-database"
            mount_path = "/etc/metabase/database"
            read_only  = true
          }

          liveness_probe {
            http_get {
              path = "/api/health"
              port = "http"
            }

            initial_delay_seconds = 120
            period_seconds        = 30
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/api/health"
              port = "http"
            }

            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_user                = 2000
            run_as_group               = 2000
            run_as_non_root            = true

            capabilities {
              drop = ["ALL"]
            }
          }

          resources {
            limits = {
              cpu    = "1"
              memory = "2Gi"
            }
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
          }
        }

        volume {
          name = "runtime"

          empty_dir {}
        }

        volume {
          name = "application-database"

          secret {
            secret_name = var.application_database_secret_name

            items {
              key  = "MB_DB_CONNECTION_URI"
              path = "connection-uri"
            }
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
