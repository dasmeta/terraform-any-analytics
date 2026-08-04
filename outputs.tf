output "service_endpoints" {
  value       = local.service_endpoints
  description = "Internal HTTP service endpoints for selected long-running analytics runtimes."
}

output "release_statuses" {
  value       = local.release_statuses
  description = "Helm-reported release status for selected analytics runtimes."
}

output "visualization_provider" {
  value       = try(var.visualization.provider, null)
  description = "Selected visualization provider, or null when visualization is omitted."
}
