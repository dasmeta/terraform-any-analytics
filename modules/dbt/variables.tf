variable "name" {
  type        = string
  description = "Helm release and dbt CronJob name."

  validation {
    condition     = length(var.name) <= 52 && can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.name))
    error_message = "name must be a lowercase DNS label of 52 characters or fewer so Kubernetes can create Jobs from the CronJob."
  }
}

variable "namespace" {
  type        = string
  description = "Existing Kubernetes namespace where the dbt CronJob is deployed."

  validation {
    condition     = length(trimspace(var.namespace)) > 0
    error_message = "namespace must not be empty."
  }
}

variable "chart_version" {
  type        = string
  default     = "0.1.39"
  description = "Released DasMeta base-cronjob chart version."
}

variable "image" {
  type = object({
    repository  = string                           # Data-product image repository, including registry when applicable.
    tag         = string                           # Immutable data-product image tag.
    pull_policy = optional(string, "IfNotPresent") # Kubernetes image pull policy for dbt runs.
  })
  description = "Data-product-owned image used by the native dbt command."

  validation {
    condition = (
      length(trimspace(var.image.repository)) > 0 &&
      length(trimspace(var.image.tag)) > 0 &&
      contains(["Always", "IfNotPresent", "Never"], var.image.pull_policy)
    )
    error_message = "image repository and tag must not be empty, and pull_policy must be Always, IfNotPresent, or Never."
  }
}

variable "command" {
  type        = list(string)
  description = "Explicit native dbt command and arguments executed by the data-product image."

  validation {
    condition     = length(var.command) > 0 && alltrue([for argument in var.command : length(trimspace(argument)) > 0])
    error_message = "command must contain at least one non-empty argument."
  }
}

variable "schedule" {
  type        = string
  description = "Kubernetes CronJob schedule for the dbt run."

  validation {
    condition     = length(trimspace(var.schedule)) > 0
    error_message = "schedule must not be empty."
  }
}

variable "configuration_secret_name" {
  type        = string
  description = "Existing Secret injected as environment variables for dbt profiles and warehouse credentials."

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9.]*[a-z0-9])?$", var.configuration_secret_name))
    error_message = "configuration_secret_name must be a valid lowercase Kubernetes Secret name."
  }
}

variable "configuration_secret_keys" {
  type        = list(string)
  description = "Keys from configuration_secret_name injected into the dbt container as environment variables."

  validation {
    condition     = length(var.configuration_secret_keys) > 0 && alltrue([for key in var.configuration_secret_keys : length(trimspace(key)) > 0])
    error_message = "configuration_secret_keys must contain at least one non-empty Secret key."
  }
}

variable "suspend" {
  type        = bool
  default     = false
  description = "When true, keep the CronJob definition but suspend future scheduled dbt runs."
}
