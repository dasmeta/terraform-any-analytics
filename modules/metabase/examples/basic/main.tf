module "metabase" {
  source = "../.."

  namespace                        = "example-platform"
  application_database_secret_name = "metabase-application-database"
}
