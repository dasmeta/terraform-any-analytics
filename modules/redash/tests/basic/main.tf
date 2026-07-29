module "redash" {
  source = "../.."

  namespace                 = "test-platform"
  configuration_secret_name = "redash-configuration"
}

output "service_name" {
  value = module.redash.service_name
}
