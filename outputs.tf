locals {
  service_endpoints = merge(
    length(module.airbyte) == 0 ? {} : {
      airbyte = {
        service_name = module.airbyte[0].webapp_service_name
        service_port = module.airbyte[0].webapp_service_port
      }
    },
    length(module.postgrest) == 0 ? {} : {
      postgrest = {
        service_name = module.postgrest[0].service_name
        service_port = module.postgrest[0].service_port
      }
    },
    length(module.metabase) == 0 ? {} : {
      metabase = {
        service_name = module.metabase[0].service_name
        service_port = module.metabase[0].service_port
      }
    },
    length(module.redash) == 0 ? {} : {
      redash = {
        service_name = module.redash[0].service_name
        service_port = module.redash[0].service_port
      }
    },
  )

  release_statuses = merge(
    length(module.airbyte) == 0 ? {} : { airbyte = module.airbyte[0].release_status },
    length(module.dbt) == 0 ? {} : { dbt = module.dbt[0].release_status },
    length(module.postgrest) == 0 ? {} : { postgrest = module.postgrest[0].release_status },
    length(module.metabase) == 0 ? {} : { metabase = module.metabase[0].release_status },
    length(module.redash) == 0 ? {} : { redash = module.redash[0].release_status },
  )
}

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
