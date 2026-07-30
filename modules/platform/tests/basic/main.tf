module "platform" {
  source = "../.."

  namespace = "test-analytics"

  airbyte = {
    database = {
      host        = "postgresql.test.internal"
      name        = "airbyte"
      secret_name = "airbyte-database"
    }
    storage = {
      bucket      = "test-airbyte"
      region      = "test-region-1"
      secret_name = "airbyte-storage"
    }
  }

  dbt = {
    image = {
      repository = "registry.example.com/data-products/test-dbt"
      tag        = "1.0.0"
    }
    command                   = ["dbt", "build"]
    schedule                  = "0 2 * * *"
    configuration_secret_name = "test-dbt-configuration"
    configuration_secret_keys = ["DBT_TARGET", "DBT_USER", "DBT_PASSWORD"]
  }

  postgrest = {
    configuration_secret_name = "postgrest-configuration"
  }

  visualization = {
    metabase = {
      application_database_secret_name = "metabase-application-database"
    }
  }
}

output "service_endpoints" {
  value = module.platform.service_endpoints
}
