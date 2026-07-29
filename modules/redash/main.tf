locals {
  labels = {
    "app.kubernetes.io/name"       = var.name
    "app.kubernetes.io/managed-by" = "terraform"
  }

  runtime_components = {
    server = {
      command  = "server"
      replicas = var.server_replicas
      queues   = null
      workers  = null
    }
    scheduler = {
      command  = "scheduler"
      replicas = 1
      queues   = null
      workers  = null
    }
    scheduled-worker = {
      command  = "worker"
      replicas = 1
      queues   = "scheduled_queries,schemas"
      workers  = 1
    }
    adhoc-worker = {
      command  = "worker"
      replicas = 1
      queues   = "queries"
      workers  = 2
    }
    default-worker = {
      command  = "worker"
      replicas = 1
      queues   = "periodic,emails,default"
      workers  = 1
    }
  }

  load_configuration = <<-EOT
    export REDASH_DATABASE_URL="$(cat /etc/redash/configuration/REDASH_DATABASE_URL)"
    export REDASH_REDIS_URL="$(cat /etc/redash/configuration/REDASH_REDIS_URL)"
    export REDASH_COOKIE_SECRET="$(cat /etc/redash/configuration/REDASH_COOKIE_SECRET)"
    export REDASH_SECRET_KEY="$(cat /etc/redash/configuration/REDASH_SECRET_KEY)"
    export PYTHONDONTWRITEBYTECODE=1
  EOT
}

resource "kubernetes_job_v1" "initialize" {
  metadata {
    name      = "${var.name}-initialize"
    namespace = var.namespace
    labels    = merge(local.labels, { "app.kubernetes.io/component" = "initialize" })
  }

  wait_for_completion = true

  spec {
    backoff_limit              = 6
    ttl_seconds_after_finished = 3600

    template {
      metadata {
        labels = merge(local.labels, { "app.kubernetes.io/component" = "initialize" })
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false
        restart_policy                  = "OnFailure"

        container {
          name              = "initialize"
          image             = var.image
          image_pull_policy = "Always"
          command           = ["/bin/bash", "-ec"]
          args              = ["${local.load_configuration}\nexec /app/bin/docker-entrypoint create_db"]

          volume_mount {
            name       = "configuration"
            mount_path = "/etc/redash/configuration"
            read_only  = true
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true

            capabilities {
              drop = ["ALL"]
            }
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "1Gi"
            }
            requests = {
              cpu    = "100m"
              memory = "256Mi"
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

resource "kubernetes_deployment_v1" "this" {
  for_each = local.runtime_components

  metadata {
    name      = "${var.name}-${each.key}"
    namespace = var.namespace
    labels    = merge(local.labels, { "app.kubernetes.io/component" = each.key })
  }

  spec {
    replicas = each.value.replicas

    selector {
      match_labels = merge(local.labels, { "app.kubernetes.io/component" = each.key })
    }

    template {
      metadata {
        labels = merge(local.labels, { "app.kubernetes.io/component" = each.key })
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false

        container {
          name              = each.key
          image             = var.image
          image_pull_policy = "Always"
          command           = ["/bin/bash", "-ec"]
          args = [join("\n", compact([
            local.load_configuration,
            each.value.queues == null ? null : "export QUEUES=${each.value.queues}",
            each.value.workers == null ? null : "export WORKERS_COUNT=${each.value.workers}",
            "exec /app/bin/docker-entrypoint ${each.value.command}",
          ]))]

          dynamic "port" {
            for_each = each.key == "server" ? [1] : []

            content {
              container_port = 5000
              name           = "http"
            }
          }

          volume_mount {
            name       = "configuration"
            mount_path = "/etc/redash/configuration"
            read_only  = true
          }

          volume_mount {
            name       = "runtime"
            mount_path = "/tmp"
          }

          dynamic "liveness_probe" {
            for_each = each.key == "server" ? [1] : []

            content {
              http_get {
                path = "/ping"
                port = "http"
              }

              initial_delay_seconds = 60
              period_seconds        = 30
              timeout_seconds       = 5
              failure_threshold     = 3
            }
          }

          dynamic "readiness_probe" {
            for_each = each.key == "server" ? [1] : []

            content {
              http_get {
                path = "/ping"
                port = "http"
              }

              initial_delay_seconds = 20
              period_seconds        = 10
              timeout_seconds       = 5
              failure_threshold     = 6
            }
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true

            capabilities {
              drop = ["ALL"]
            }
          }

          resources {
            limits = {
              cpu    = each.key == "server" ? "1" : "500m"
              memory = each.key == "server" ? "2Gi" : "1Gi"
            }
            requests = {
              cpu    = each.key == "server" ? "250m" : "100m"
              memory = each.key == "server" ? "512Mi" : "256Mi"
            }
          }
        }

        volume {
          name = "configuration"

          secret {
            secret_name = var.configuration_secret_name
          }
        }

        volume {
          name = "runtime"

          empty_dir {}
        }
      }
    }
  }

  depends_on = [kubernetes_job_v1.initialize]
}

resource "kubernetes_service_v1" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = merge(local.labels, { "app.kubernetes.io/component" = "server" })
  }

  spec {
    type = "ClusterIP"
    selector = merge(local.labels, {
      "app.kubernetes.io/component" = "server"
    })

    port {
      name        = "http"
      port        = 5000
      target_port = "http"
    }
  }
}
