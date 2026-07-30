locals {
  metabase_enabled = try(var.visualization.provider == "metabase", false)
  redash_enabled   = try(var.visualization.provider == "redash", false)
}

module "airbyte" {
  count  = var.airbyte == null ? 0 : 1
  source = "./modules/airbyte"

  name          = var.airbyte.name
  namespace     = var.namespace
  chart_version = var.airbyte.chart_version
  database      = var.airbyte.database
  storage       = var.airbyte.storage
}

module "dbt" {
  count  = var.dbt == null ? 0 : 1
  source = "./modules/dbt"

  name                      = var.dbt.name
  namespace                 = var.namespace
  chart_version             = var.dbt.chart_version
  image                     = var.dbt.image
  command                   = var.dbt.command
  schedule                  = var.dbt.schedule
  configuration_secret_name = var.dbt.configuration_secret_name
  configuration_secret_keys = var.dbt.configuration_secret_keys
  suspend                   = var.dbt.suspend
}

module "postgrest" {
  count  = var.postgrest == null ? 0 : 1
  source = "./modules/postgrest"

  name                      = var.postgrest.name
  namespace                 = var.namespace
  chart_version             = var.postgrest.chart_version
  configuration_secret_name = var.postgrest.configuration_secret_name
  replicas                  = var.postgrest.replicas
}

module "metabase" {
  count  = local.metabase_enabled ? 1 : 0
  source = "./modules/metabase"

  name                             = var.visualization.metabase.name
  namespace                        = var.namespace
  chart_version                    = var.visualization.metabase.chart_version
  application_database_secret_name = var.visualization.metabase.application_database_secret_name
  replicas                         = var.visualization.metabase.replicas
}

module "redash" {
  count  = local.redash_enabled ? 1 : 0
  source = "./modules/redash"

  name                      = var.visualization.redash.name
  namespace                 = var.namespace
  chart_version             = var.visualization.redash.chart_version
  configuration_secret_name = var.visualization.redash.configuration_secret_name
  server_replicas           = var.visualization.redash.server_replicas
}
