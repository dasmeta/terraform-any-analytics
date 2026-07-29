locals {
  values = {
    jobs = [
      {
        name                       = var.name
        schedule                   = var.schedule
        command                    = var.command
        restartPolicy              = "Never"
        concurrencyPolicy          = "Forbid"
        successfulJobsHistoryLimit = 3
        failedJobsHistoryLimit     = 1
        jobBackoffLimit            = 1
        suspend                    = var.suspend
        imagePullPolicy            = var.image.pull_policy
        image = {
          repository = var.image.repository
          tag        = var.image.tag
        }
        secrets = [
          for key in var.configuration_secret_keys : {
            (key) = {
              from = var.configuration_secret_name
              key  = key
            }
          }
        ]
        serviceAccount = {
          create = false
        }
        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "1Gi"
          }
        }
      }
    ]
  }
}

resource "helm_release" "this" {
  name             = var.name
  repository       = "https://dasmeta.github.io/helm"
  chart            = "base-cronjob"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = false

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 900

  values = [yamlencode(local.values)]
}
