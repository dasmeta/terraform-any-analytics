module "dbt" {
  source = "../.."

  name                      = "test-dbt-build"
  namespace                 = "test-platform"
  image                     = "registry.example.com/data-products/test-dbt:1.0.0"
  command                   = ["dbt", "build"]
  schedule                  = "0 2 * * *"
  configuration_secret_name = "test-dbt-configuration"
}

output "cron_job_name" {
  value = module.dbt.cron_job_name
}
