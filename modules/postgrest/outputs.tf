output "service_name" {
  value       = var.name
  description = "PostgREST ClusterIP Service name."
}

output "service_port" {
  value       = 3000
  description = "PostgREST ClusterIP Service HTTP port."
}

output "release_status" {
  value       = helm_release.this.status
  description = "Helm-reported PostgREST release status."
}
