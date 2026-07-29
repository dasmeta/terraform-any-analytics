module "postgrest" {
  source = "../.."

  namespace                 = "example-platform"
  configuration_secret_name = "postgrest-configuration"
}
