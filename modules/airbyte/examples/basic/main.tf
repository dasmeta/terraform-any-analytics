module "airbyte" {
  source = "../.."

  namespace = "example-platform"

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

output "webapp_service_name" {
  value = module.airbyte.webapp_service_name
}
