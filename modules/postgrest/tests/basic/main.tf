module "postgrest" {
  source = "../.."

  namespace                 = "test-platform"
  configuration_secret_name = "postgrest-configuration"
}

output "service_name" {
  value = module.postgrest.service_name
}
