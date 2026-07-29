variable "name" {
  type        = string
  default     = "postgrest"
  description = "Deployment and ClusterIP Service name."
}

variable "namespace" {
  type        = string
  description = "Existing Kubernetes namespace where PostgREST is deployed."
}

variable "image" {
  type        = string
  default     = "postgrest/postgrest@sha256:d09618df2b7b9547c80a076c2f4045b326be8d7ac06060d263caefec1334e3c9"
  description = "Official immutable PostgREST v13.0.8 container image reference."
}

variable "configuration_secret_name" {
  type        = string
  description = "Existing Secret containing a postgrest.conf configuration file with database and JWT/JWK verification settings."
}

variable "replicas" {
  type        = number
  default     = 1
  description = "Number of PostgREST replicas."
}
