output "service_name" {
  value       = "${var.name}-redash-server"
  description = "Name of the Redash server ClusterIP Service."
}

output "service_port" {
  value       = 5000
  description = "HTTP port exposed by the Redash server ClusterIP Service."
}

output "server_deployment_name" {
  value       = "${var.name}-redash-server"
  description = "Name of the Redash server Deployment."
}

output "release_status" {
  value       = helm_release.this.status
  description = "Helm-reported Redash release status."
}
