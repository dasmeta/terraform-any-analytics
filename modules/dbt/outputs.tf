output "cron_job_name" {
  value       = var.name
  description = "Name of the dbt CronJob managed by the Helm release."
}

output "cron_job_namespace" {
  value       = helm_release.this.namespace
  description = "Namespace of the dbt Helm release."
}

output "release_status" {
  value       = helm_release.this.status
  description = "Helm-reported dbt release status."
}
