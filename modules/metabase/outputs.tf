output "service_name" {
  value       = var.name
  description = "Metabase ClusterIP Service name."
}

output "service_port" {
  value       = 3000
  description = "Metabase ClusterIP Service HTTP port."
}

output "deployment_name" {
  value       = var.name
  description = "Metabase Deployment name rendered by the component chart."
}

output "release_status" {
  value       = helm_release.this.status
  description = "Helm-reported Metabase release status."
}
