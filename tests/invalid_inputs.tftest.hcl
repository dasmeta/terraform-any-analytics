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

run "rejects_missing_selected_visualization_configuration" {
  command = plan

  variables {
    namespace = "test-analytics"
    visualization = {
      provider = "metabase"
    }
  }

  expect_failures = [
    var.visualization,
  ]
}

run "allows_omitted_visualization" {
  command = plan

  variables {
    namespace = "test-analytics"
  }

  assert {
    condition     = length(module.metabase) == 0 && length(module.redash) == 0
    error_message = "Omitting visualization must deploy neither visualization provider."
  }
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

run "selects_default_metabase_and_selected_runtime_outputs" {
  command = plan

  variables {
    namespace = "test-analytics"
    airbyte = {
      database = {
        host        = "postgresql.test.internal"
        name        = "airbyte"
        secret_name = "airbyte-database"
      }
      storage = {
        bucket      = "test-airbyte"
        region      = "test-region-1"
        secret_name = "airbyte-storage"
      }
    }
    dbt = {
      image = {
        repository = "registry.example.com/data-products/test-dbt"
        tag        = "1.0.0"
      }
      command                   = ["dbt", "build"]
      schedule                  = "0 2 * * *"
      configuration_secret_name = "test-dbt-configuration"
      configuration_secret_keys = ["DBT_TARGET", "DBT_USER", "DBT_PASSWORD"]
    }
    postgrest = {
      configuration_secret_name = "postgrest-configuration"
    }
    visualization = {
      metabase = {
        application_database_secret_name = "metabase-application-database"
      }
    }
  }

  assert {
    condition = (
      length(module.airbyte) == 1 &&
      length(module.dbt) == 1 &&
      length(module.postgrest) == 1 &&
      length(module.metabase) == 1 &&
      length(module.redash) == 0
    )
    error_message = "The default selection must compose Airbyte, dbt, PostgREST, and only Metabase."
  }

  assert {
    condition     = output.visualization_provider == "metabase"
    error_message = "Metabase must be reported when visualization.provider is omitted."
  }

  assert {
    condition = output.service_endpoints == {
      airbyte = {
        service_name = "airbyte-airbyte-webapp-svc"
        service_port = 80
      }
      postgrest = {
        service_name = "postgrest"
        service_port = 3000
      }
      metabase = {
        service_name = "metabase"
        service_port = 3000
      }
    }
    error_message = "Service endpoints must include only selected long-running runtime services."
  }
}
