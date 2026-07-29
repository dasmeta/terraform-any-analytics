module "dbt" {
  source = "../.."

  name      = "test-dbt-build"
  namespace = "test-platform"
  image = {
    repository = "registry.example.com/data-products/test-dbt"
    tag        = "1.0.0"
  }
  command                   = ["dbt", "build"]
  schedule                  = "0 2 * * *"
  configuration_secret_name = "test-dbt-configuration"
  configuration_secret_keys = ["DBT_TARGET", "DBT_USER", "DBT_PASSWORD"]
}

output "cron_job_name" {
  value = module.dbt.cron_job_name
}
