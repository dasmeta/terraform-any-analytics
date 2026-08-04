locals {
  metabase_enabled = try(var.visualization.provider == "metabase", false)
  redash_enabled   = try(var.visualization.provider == "redash", false)

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
