locals {
  values = {
    base = {
      fullnameOverride = var.name
      replicaCount     = var.replicas
      envFrom = {
        secret = var.application_database_secret_name
      }
      extraEnv = {
        MB_DB_TYPE = "postgres"
      }
      serviceAccount = {
        create = false
      }
      podSecurityContext = {
        fsGroup      = 2000
        runAsUser    = 2000
        runAsGroup   = 2000
        runAsNonRoot = true
      }
      securityContext = {
        allowPrivilegeEscalation = false
        readOnlyRootFilesystem   = true
        runAsUser                = 2000
        runAsGroup               = 2000
        runAsNonRoot             = true
        capabilities = {
          drop = ["ALL"]
        }
      }
      workingDir = "/tmp"
      volumes = [
        {
          name      = "runtime"
          mountPath = "/tmp"
          emptyDir  = {}
        }
      ]
      readinessProbe = {
        httpGet = {
          path = "/api/health"
          port = "http"
        }
        initialDelaySeconds = 30
        periodSeconds       = 10
        timeoutSeconds      = 5
        failureThreshold    = 6
      }
      livenessProbe = {
        httpGet = {
          path = "/api/health"
          port = "http"
        }
        initialDelaySeconds = 120
        periodSeconds       = 30
        timeoutSeconds      = 5
        failureThreshold    = 3
      }
      resources = {
        requests = {
          cpu    = "250m"
          memory = "512Mi"
        }
        limits = {
          cpu    = "1"
          memory = "2Gi"
        }
      }
    }
  }
}

resource "helm_release" "this" {
  name             = var.name
  repository       = "https://dasmeta.github.io/helm"
  chart            = "metabase"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = false

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 900

  values = [yamlencode(local.values)]
}
