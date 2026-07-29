module "dbt" {
  source = "../.."

  name                      = "example-dbt-build"
  namespace                 = "example-platform"
  image                     = "registry.example.com/data-products/example-dbt:1.0.0"
  command                   = ["dbt", "build", "--target", "production"]
  schedule                  = "0 2 * * *"
  configuration_secret_name = "example-dbt-configuration"
}
