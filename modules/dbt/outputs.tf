output "cron_job_name" {
  value       = kubernetes_cron_job_v1.this.metadata[0].name
  description = "Name of the managed dbt Kubernetes CronJob."
}

output "cron_job_namespace" {
  value       = kubernetes_cron_job_v1.this.metadata[0].namespace
  description = "Namespace of the managed dbt Kubernetes CronJob."
}
