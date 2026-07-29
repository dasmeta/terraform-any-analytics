variable "name" {
  type        = string
  default     = "airbyte"
  description = "Helm release name and prefix for derived Airbyte resource names."

  validation {
    condition     = length(var.name) <= 43 && can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.name))
    error_message = "name must be a lowercase DNS label of 43 characters or fewer so the derived webapp Service name remains valid."
  }
}

variable "namespace" {
  type        = string
  description = "Existing Kubernetes namespace where Airbyte is deployed."

  validation {
    condition     = length(trimspace(var.namespace)) > 0
    error_message = "namespace must not be empty."
  }
}

variable "chart_version" {
  type        = string
  default     = "1.9.2"
  description = "Reviewed version of the official Airbyte Helm chart."

  validation {
    condition     = length(trimspace(var.chart_version)) > 0
    error_message = "chart_version must not be empty."
  }
}

variable "database" {
  type = object({
    host                = string                       # External PostgreSQL hostname or service name.
    name                = string                       # Existing PostgreSQL database name.
    port                = optional(number, 5432)       # External PostgreSQL TCP port.
    secret_name         = string                       # Existing Secret containing database credentials.
    user_secret_key     = optional(string, "username") # Key holding the database username in secret_name.
    password_secret_key = optional(string, "password") # Key holding the database password in secret_name.
  })
  description = "External PostgreSQL endpoint metadata and an existing Secret reference for the Airbyte database credentials."

  validation {
    condition = (
      length(trimspace(var.database.host)) > 0 &&
      length(trimspace(var.database.name)) > 0 &&
      length(trimspace(var.database.secret_name)) > 0 &&
      length(trimspace(var.database.user_secret_key)) > 0 &&
      length(trimspace(var.database.password_secret_key)) > 0 &&
      var.database.port >= 1 && var.database.port <= 65535
    )
    error_message = "database host, name, Secret name, and Secret keys must not be empty, and port must be between 1 and 65535."
  }
}

variable "storage" {
  type = object({
    bucket                       = string                                   # Existing S3 bucket used for all Airbyte storage classes.
    region                       = string                                   # AWS region containing bucket.
    secret_name                  = string                                   # Existing Secret containing S3 credentials.
    access_key_id_secret_key     = optional(string, "s3-access-key-id")     # Key holding the S3 access key ID in secret_name.
    secret_access_key_secret_key = optional(string, "s3-secret-access-key") # Key holding the S3 secret access key in secret_name.
  })
  description = "Existing AWS S3 storage contract and a Secret reference for Airbyte credentials."

  validation {
    condition = (
      length(trimspace(var.storage.bucket)) > 0 &&
      length(trimspace(var.storage.region)) > 0 &&
      length(trimspace(var.storage.secret_name)) > 0 &&
      length(trimspace(var.storage.access_key_id_secret_key)) > 0 &&
      length(trimspace(var.storage.secret_access_key_secret_key)) > 0
    )
    error_message = "storage bucket, region, Secret name, and Secret keys must not be empty."
  }
}
