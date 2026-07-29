module "metabase" {
  source = "../.."

  namespace                        = "test-platform"
  application_database_secret_name = "metabase-application-database"
}

output "service_name" {
  value = module.metabase.service_name
}
