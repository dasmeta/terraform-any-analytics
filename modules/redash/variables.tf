variable "name" {
  type        = string
  default     = "redash"
  description = "Helm release name used to derive Redash component resource names."

  validation {
    condition     = length(var.name) <= 49 && can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.name))
    error_message = "name must be a lowercase DNS label of 49 characters or fewer so the derived Redash server Service name is valid."
  }
}

variable "namespace" {
  type        = string
  description = "Existing Kubernetes namespace where Redash is deployed."
}

variable "chart_version" {
  type        = string
  default     = "0.1.0"
  description = "Released DasMeta Redash chart version."
}

variable "configuration_secret_name" {
  type        = string
  description = "Existing Secret containing REDASH_DATABASE_URL, REDASH_REDIS_URL, REDASH_COOKIE_SECRET, and REDASH_SECRET_KEY."
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
