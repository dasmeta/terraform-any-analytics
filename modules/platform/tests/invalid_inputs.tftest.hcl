mock_provider "helm" {}

run "rejects_unknown_visualization_provider" {
  command = plan

  variables {
    namespace = "test-analytics"
    visualization = {
      provider = "unsupported"
    }
  }

  expect_failures = [
    var.visualization,
  ]
}

run "rejects_ambiguous_visualization_configuration" {
  command = plan

  variables {
    namespace = "test-analytics"
    visualization = {
      provider = "metabase"
      metabase = {
        application_database_secret_name = "metabase-application-database"
      }
      redash = {
        configuration_secret_name = "redash-configuration"
      }
    }
  }

  expect_failures = [
    var.visualization,
  ]
}

run "selects_redash_without_metabase" {
  command = plan

  variables {
    namespace = "test-analytics"
    visualization = {
      provider = "redash"
      redash = {
        configuration_secret_name = "redash-configuration"
      }
    }
  }

  assert {
    condition     = length(module.redash) == 1 && length(module.metabase) == 0
    error_message = "A Redash selection must not also deploy Metabase."
  }
}
