module "dbt" {
  source = "../.."

  name      = "example-dbt-build"
  namespace = "example-platform"
  image = {
    repository = "registry.example.com/data-products/example-dbt"
    tag        = "1.0.0"
  }
  command                   = ["dbt", "build", "--target", "production"]
  schedule                  = "0 2 * * *"
  configuration_secret_name = "example-dbt-configuration"
  configuration_secret_keys = ["DBT_TARGET", "DBT_USER", "DBT_PASSWORD"]
}
