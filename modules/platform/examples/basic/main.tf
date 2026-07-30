module "platform" {
  source = "../.."

  namespace = "example-analytics"

  airbyte = {
    database = {
      host        = "postgresql.example.internal"
      name        = "airbyte"
      secret_name = "airbyte-database"
    }
    storage = {
      bucket      = "example-airbyte"
      region      = "example-region-1"
      secret_name = "airbyte-storage"
    }
  }

  dbt = {
    image = {
      repository = "registry.example.com/data-products/example-dbt"
      tag        = "1.0.0"
    }
    command                   = ["dbt", "build", "--target", "production"]
    schedule                  = "0 2 * * *"
    configuration_secret_name = "example-dbt-configuration"
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
