locals {
  values = {
    global = {
      database = {
        type              = "external"
        host              = var.database.host
        port              = var.database.port
        database          = var.database.name
        secretName        = var.database.secret_name
        userSecretKey     = var.database.user_secret_key
        passwordSecretKey = var.database.password_secret_key
      }

      storage = {
        type       = "s3"
        secretName = var.storage.secret_name
        bucket = {
          activityPayload = var.storage.bucket
          auditLogging    = var.storage.bucket
          log             = var.storage.bucket
          state           = var.storage.bucket
          workloadOutput  = var.storage.bucket
        }
        s3 = {
          authenticationType       = "credentials"
          region                   = var.storage.region
          accessKeyIdSecretKey     = var.storage.access_key_id_secret_key
          secretAccessKeySecretKey = var.storage.secret_access_key_secret_key
        }
      }
    }

    postgresql = {
      enabled = false
    }

    webapp = {
      enabled = true
      service = {
        type = "ClusterIP"
        port = 80
      }
    }
  }
}

resource "helm_release" "this" {
  name             = var.name
  repository       = "https://airbytehq.github.io/helm-charts"
  chart            = "airbyte"
  namespace        = var.namespace
  version          = var.chart_version
  create_namespace = false

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 900

  values = [yamlencode(local.values)]
}
