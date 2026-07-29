output "service_name" {
  value       = kubernetes_service_v1.this.metadata[0].name
  description = "Name of the managed Redash ClusterIP Service."
}

output "service_port" {
  value       = kubernetes_service_v1.this.spec[0].port[0].port
  description = "HTTP port exposed by the managed Redash ClusterIP Service."
}

output "server_deployment_name" {
  value       = kubernetes_deployment_v1.this["server"].metadata[0].name
  description = "Name of the managed Redash server Deployment."
}
