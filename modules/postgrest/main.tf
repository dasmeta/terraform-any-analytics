locals {
  values = {
    base = {
      fullnameOverride = var.name
      replicaCount     = var.replicas
      envFrom = {
        secret = var.configuration_secret_name
      }
      serviceAccount = {
        create = false
      }
      securityContext = {
        allowPrivilegeEscalation = false
        readOnlyRootFilesystem   = true
        runAsNonRoot             = true
        capabilities = {
          drop = ["ALL"]
        }
      }
      readinessProbe = {
        tcpSocket = {
          port = "http"
        }
      }
      livenessProbe = {
        tcpSocket = {
          port = "http"
        }
      }
      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }
    }
  }
}

resource "helm_release" "this" {
  name             = var.name
  repository       = "https://dasmeta.github.io/helm"
  chart            = "postgrest"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = false

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 900

  values = [yamlencode(local.values)]
}
