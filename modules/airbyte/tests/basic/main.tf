module "airbyte" {
  source = "../.."

  namespace = "test-platform"

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

output "webapp_service_name" {
  value = module.airbyte.webapp_service_name
}

output "webapp_service_port" {
  value = module.airbyte.webapp_service_port
}
