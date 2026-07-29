variable "name" {
  type        = string
  default     = "metabase"
  description = "Deployment and ClusterIP Service name."
}

variable "namespace" {
  type        = string
  description = "Existing Kubernetes namespace where Metabase is deployed."
}

variable "image" {
  type        = string
  default     = "metabase/metabase@sha256:a6e4100e913165ab2f2d5ac36bc1a2f63edd0ff5b2292e7a10642351598e1de7"
  description = "Official immutable Metabase Open Source v0.63.1.12 container image reference."
}

variable "application_database_secret_name" {
  type        = string
  description = "Existing Secret containing the MB_DB_CONNECTION_URI key for Metabase's external PostgreSQL application database."
}

variable "replicas" {
  type        = number
  default     = 1
  description = "Number of Metabase replicas; retain one replica during application database migrations."

  validation {
    condition     = var.replicas >= 1
    error_message = "replicas must be at least one."
  }
}
