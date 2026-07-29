variable "name" {
  type        = string
  description = "Name of the dbt Kubernetes CronJob."

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

variable "image" {
  type        = string
  description = "Data-product-owned container image containing the dbt project and runtime."

  validation {
    condition     = length(trimspace(var.image)) > 0
    error_message = "image must not be empty."
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
  description = "Existing Secret name injected as environment variables for dbt profiles and warehouse credentials."

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9.]*[a-z0-9])?$", var.configuration_secret_name))
    error_message = "configuration_secret_name must be a valid lowercase Kubernetes Secret name."
  }
}

variable "suspend" {
  type        = bool
  default     = false
  description = "When true, keep the CronJob definition but suspend future scheduled dbt runs."
}
