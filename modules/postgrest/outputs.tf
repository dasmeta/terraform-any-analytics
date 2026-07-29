output "service_name" {
  value       = kubernetes_service_v1.this.metadata[0].name
  description = "Internal PostgREST ClusterIP Service name."
}

output "service_namespace" {
  value       = kubernetes_service_v1.this.metadata[0].namespace
  description = "Namespace of the PostgREST Service."
}

output "service_port" {
  value       = 3000
  description = "Internal PostgREST HTTP Service port."
}
