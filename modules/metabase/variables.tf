variable "name" {
  type        = string
  default     = "metabase"
  description = "Helm release, Deployment, and ClusterIP Service name."
}

variable "namespace" {
  type        = string
  description = "Existing Kubernetes namespace where Metabase is deployed."
}

variable "chart_version" {
  type        = string
  default     = "0.1.0"
  description = "Released DasMeta Metabase chart version."
}

variable "application_database_secret_name" {
  type        = string
  description = "Existing Secret containing the MB_DB_CONNECTION_URI value for Metabase's external PostgreSQL application database."
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
