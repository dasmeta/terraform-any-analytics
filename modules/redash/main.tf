locals {
  redash_image = {
    repository = "redash/redash"
    tag        = "26.3.0@sha256:c5c9148f5c389c9373224bde7053b4a1652fd696ee881dce00a064d21ccdcba8"
    pullPolicy = "IfNotPresent"
  }

  common_component_values = {
    image = local.redash_image
    envFrom = {
      secret = var.configuration_secret_name
    }
    serviceAccount = {
      create = false
    }
    volumes = [
      {
        name      = "runtime"
        mountPath = "/tmp"
        emptyDir  = {}
      }
    ]
    securityContext = {
      allowPrivilegeEscalation = false
      readOnlyRootFilesystem   = true
      runAsNonRoot             = true
      capabilities = {
        drop = ["ALL"]
      }
    }
  }

  worker_resources = {
    requests = {
      cpu    = "100m"
      memory = "256Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "1Gi"
    }
  }

  values = {
    server = merge(local.common_component_values, {
      replicaCount = var.server_replicas
      initContainers = [
        {
          name  = "create-database"
          image = local.redash_image
          args  = ["create_db"]
          envFrom = [
            {
              secretRef = {
                name = var.configuration_secret_name
              }
            }
          ]
        }
      ]
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
      readinessProbe = {
        httpGet = {
          path = "/ping"
          port = "http"
        }
        initialDelaySeconds = 20
        periodSeconds       = 10
        timeoutSeconds      = 5
        failureThreshold    = 6
      }
      livenessProbe = {
        httpGet = {
          path = "/ping"
          port = "http"
        }
        initialDelaySeconds = 60
        periodSeconds       = 30
        timeoutSeconds      = 5
        failureThreshold    = 3
      }
    })
    scheduler = merge(local.common_component_values, {
      resources = local.worker_resources
    })
    scheduledWorker = merge(local.common_component_values, {
      resources = local.worker_resources
    })
    adhocWorker = merge(local.common_component_values, {
      resources = local.worker_resources
    })
    defaultWorker = merge(local.common_component_values, {
      resources = local.worker_resources
    })
  }
}

resource "helm_release" "this" {
  name             = var.name
  repository       = "https://dasmeta.github.io/helm"
  chart            = "redash"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = false

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 900

  values = [yamlencode(local.values)]
}
