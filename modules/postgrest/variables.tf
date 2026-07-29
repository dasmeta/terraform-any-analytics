variable "name" {
  type        = string
  default     = "postgrest"
  description = "Helm release, Deployment, and ClusterIP Service name."
}

variable "namespace" {
  type        = string
  description = "Existing Kubernetes namespace where PostgREST is deployed."
}

variable "chart_version" {
  type        = string
  default     = "0.1.0"
  description = "Released DasMeta PostgREST chart version."
}

variable "configuration_secret_name" {
  type        = string
  description = "Existing Secret containing PGRST_* database, schema, role, and JWT configuration variables."
}

variable "replicas" {
  type        = number
  default     = 1
  description = "Number of PostgREST replicas."
}
