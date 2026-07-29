output "service_name" {
  value       = kubernetes_service_v1.this.metadata[0].name
  description = "Name of the managed Metabase ClusterIP Service."
}

output "service_port" {
  value       = kubernetes_service_v1.this.spec[0].port[0].port
  description = "HTTP port exposed by the managed Metabase ClusterIP Service."
}

output "deployment_name" {
  value       = kubernetes_deployment_v1.this.metadata[0].name
  description = "Name of the managed Metabase Deployment."
}
