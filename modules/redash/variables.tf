variable "name" {
  type        = string
  default     = "redash"
  description = "Prefix for Redash workload names and the ClusterIP Service name."
}

variable "namespace" {
  type        = string
  description = "Existing Kubernetes namespace where Redash is deployed."
}

variable "image" {
  type        = string
  default     = "redash/redash@sha256:c5c9148f5c389c9373224bde7053b4a1652fd696ee881dce00a064d21ccdcba8"
  description = "Official immutable Redash v26.3.0 multi-architecture container image reference."
}

variable "configuration_secret_name" {
  type        = string
  description = "Existing Secret containing REDASH_DATABASE_URL, REDASH_REDIS_URL, REDASH_COOKIE_SECRET, and REDASH_SECRET_KEY keys."
}

variable "server_replicas" {
  type        = number
  default     = 1
  description = "Number of Redash server replicas."

  validation {
    condition     = var.server_replicas >= 1
    error_message = "server_replicas must be at least one."
  }
}
