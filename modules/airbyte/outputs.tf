output "release_name" {
  value       = helm_release.this.name
  description = "Name of the Airbyte Helm release."
}

output "release_namespace" {
  value       = helm_release.this.namespace
  description = "Namespace of the Airbyte Helm release."
}

output "release_status" {
  value       = helm_release.this.status
  description = "Helm-reported Airbyte release status."
}

output "release_chart_version" {
  value       = helm_release.this.version
  description = "Chart version used by the Airbyte Helm release."
}

output "webapp_service_name" {
  value       = "${var.name}-airbyte-webapp-svc"
  description = "Internal Airbyte webapp Service name for separately managed ingress."
}

output "webapp_service_port" {
  value       = 80
  description = "Internal Airbyte webapp Service HTTP port for separately managed ingress."
}
