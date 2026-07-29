resource "kubernetes_cron_job_v1" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/component"  = "dbt-runner"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    schedule                      = var.schedule
    suspend                       = var.suspend
    concurrency_policy            = "Forbid"
    failed_jobs_history_limit     = 1
    successful_jobs_history_limit = 3

    job_template {
      metadata {
        labels = {
          "app.kubernetes.io/component" = "dbt-runner"
        }
      }

      spec {
        backoff_limit = 1

        template {
          metadata {
            labels = {
              "app.kubernetes.io/component" = "dbt-runner"
            }
          }

          spec {
            automount_service_account_token = false
            enable_service_links            = false
            restart_policy                  = "Never"

            container {
              name    = "dbt"
              image   = var.image
              command = var.command

              env_from {
                secret_ref {
                  name = var.configuration_secret_name
                }
              }
            }
          }
        }
      }
    }
  }
}
