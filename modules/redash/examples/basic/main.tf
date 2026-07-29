module "redash" {
  source = "../.."

  namespace                 = "example-platform"
  configuration_secret_name = "redash-configuration"
}
