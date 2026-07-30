variable "namespace" {
  type        = string
  description = "Existing Kubernetes namespace for all selected analytics runtimes."

  validation {
    condition     = length(trimspace(var.namespace)) > 0
    error_message = "namespace must not be empty."
  }
}

variable "airbyte" {
  type = object({
    name          = optional(string, "airbyte") # Helm release name and Airbyte resource prefix.
    chart_version = optional(string, "1.9.2")   # Reviewed official Airbyte chart version.
    database = object({
      host                = string                       # External PostgreSQL hostname or service name.
      name                = string                       # Existing PostgreSQL database name.
      port                = optional(number, 5432)       # External PostgreSQL TCP port.
      secret_name         = string                       # Existing Secret containing database credentials.
      user_secret_key     = optional(string, "username") # Username key in database secret.
      password_secret_key = optional(string, "password") # Password key in database secret.
    })
    storage = object({
      bucket                       = string                                   # Existing S3 bucket for Airbyte storage classes.
      region                       = string                                   # AWS region containing the bucket.
      secret_name                  = string                                   # Existing Secret containing S3 credentials.
      access_key_id_secret_key     = optional(string, "s3-access-key-id")     # Access-key ID key in storage secret.
      secret_access_key_secret_key = optional(string, "s3-secret-access-key") # Secret-access-key key in storage secret.
    })
  })
  default     = null
  nullable    = true
  description = "Optional Airbyte runtime configuration. Null omits Airbyte from the platform."
}

variable "dbt" {
  type = object({
    name          = optional(string, "dbt-build") # Helm release and dbt CronJob name.
    chart_version = optional(string, "0.1.39")    # Released DasMeta base-cronjob chart version.
    image = object({
      repository  = string                           # Data-product image repository, including registry when applicable.
      tag         = string                           # Immutable data-product image tag.
      pull_policy = optional(string, "IfNotPresent") # Kubernetes image pull policy.
    })
    command                   = list(string)          # Native dbt command and arguments.
    schedule                  = string                # Kubernetes CronJob schedule.
    configuration_secret_name = string                # Existing Secret injected as dbt environment variables.
    configuration_secret_keys = list(string)          # Secret keys injected into the dbt container.
    suspend                   = optional(bool, false) # Suspend future dbt runs while retaining the CronJob.
  })
  default     = null
  nullable    = true
  description = "Optional dbt runner configuration. Null omits dbt from the platform."
}

variable "postgrest" {
  type = object({
    name                      = optional(string, "postgrest") # Helm release, Deployment, and Service name.
    chart_version             = optional(string, "0.1.0")     # Released DasMeta PostgREST chart version.
    configuration_secret_name = string                        # Existing Secret containing PGRST_* configuration.
    replicas                  = optional(number, 1)           # Number of PostgREST replicas.
  })
  default     = null
  nullable    = true
  description = "Optional PostgREST runtime configuration. Null omits PostgREST from the platform."
}

variable "visualization" {
  type = object({
    provider = optional(string, "metabase") # Visualization provider to deploy: metabase or redash.
    metabase = optional(object({
      name                             = optional(string, "metabase") # Helm release, Deployment, and Service name.
      chart_version                    = optional(string, "0.1.0")    # Released DasMeta Metabase chart version.
      application_database_secret_name = string                       # Existing Secret containing MB_DB_CONNECTION_URI.
      replicas                         = optional(number, 1)          # Number of Metabase replicas.
    }))
    redash = optional(object({
      name                      = optional(string, "redash") # Helm release name used for Redash resources.
      chart_version             = optional(string, "0.1.0")  # Released DasMeta Redash chart version.
      configuration_secret_name = string                     # Existing Secret containing required REDASH_* values.
      server_replicas           = optional(number, 1)        # Number of Redash server replicas.
    }))
  })
  default     = null
  nullable    = true
  description = "Optional visualization runtime. Metabase is the default provider when this object is configured."

  validation {
    condition = var.visualization == null ? true : (
      contains(["metabase", "redash"], var.visualization.provider) &&
      (
        var.visualization.provider == "metabase" &&
        var.visualization.metabase != null &&
        var.visualization.redash == null
        ) || (
        var.visualization.provider == "redash" &&
        var.visualization.redash != null &&
        var.visualization.metabase == null
      )
    )
    error_message = "visualization must select metabase with only metabase configuration, or redash with only redash configuration."
  }
}
