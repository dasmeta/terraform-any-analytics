# Analytics Platform Terraform Module

Composes selected analytics runtime modules into one product-level deployment
root. Use it when an environment needs one reviewed configuration for the core
analytics suite. Use individual component modules when their release cadence or
state must remain independent.

## Ownership boundary

This module creates only selected local runtime modules: Airbyte, dbt,
PostgREST, and exactly one visualization provider. It does not create or look
up a namespace, Authentik, database, database user/grant, bucket, Redis,
Secret, ingress, DNS, TLS, Airbyte connection, dbt project, PostgREST schema,
or visualization content.

Create those prerequisites in their owning layer. Pass the existing namespace
(typically the output of the shared namespace module) and existing Secret
references to this module. Authentik remains a separate shared release; this
module does not claim to configure application SSO or forward-auth.

## Usage

```hcl
module "analytics_platform" {
  source = "dasmeta/analytics/any//modules/platform"

  namespace = module.analytics_namespace.name

  airbyte = {
    database = {
      host        = "postgresql.example.internal"
      name        = "airbyte"
      secret_name = "airbyte-database"
    }
    storage = {
      bucket      = "example-airbyte"
      region      = "example-region-1"
      secret_name = "airbyte-storage"
    }
  }

  postgrest = {
    configuration_secret_name = "postgrest-configuration"
  }

  visualization = {
    # provider defaults to metabase
    metabase = {
      application_database_secret_name = "metabase-application-database"
    }
  }
}
```

`airbyte`, `dbt`, `postgrest`, and `visualization` are independently optional.
Set a component to `null` or omit it to leave it out. The full neutral example
also demonstrates the dbt contract.

## Visualization selection

Metabase is the default only when a `visualization` object is supplied. It is
not implicitly deployed without its required application-database Secret.

```hcl
visualization = {
  provider = "redash"
  redash = {
    configuration_secret_name = "redash-configuration"
  }
}
```

The module rejects an unknown provider, a missing selected-provider
configuration, or configuration for both providers. It therefore cannot deploy
Metabase and Redash in the same platform release by accident. Deploy a
separate module root only when a deliberate parallel migration needs both.

## Operations

`service_endpoints` returns private service names and ports for selected
long-running runtimes. Configure Gateway/ingress, DNS, TLS, Authentik policy,
and Galust access in their respective layers using those outputs. `dbt` has no
HTTP endpoint because it is a CronJob.

This module intentionally has no generic Helm-values escape hatch. Add
service-specific capabilities to the owning component module through a
reviewed interface instead.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_airbyte"></a> [airbyte](#module\_airbyte) | ../airbyte | n/a |
| <a name="module_dbt"></a> [dbt](#module\_dbt) | ../dbt | n/a |
| <a name="module_metabase"></a> [metabase](#module\_metabase) | ../metabase | n/a |
| <a name="module_postgrest"></a> [postgrest](#module\_postgrest) | ../postgrest | n/a |
| <a name="module_redash"></a> [redash](#module\_redash) | ../redash | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_airbyte"></a> [airbyte](#input\_airbyte) | Optional Airbyte runtime configuration. Null omits Airbyte from the platform. | <pre>object({<br/>    name          = optional(string, "airbyte") # Helm release name and Airbyte resource prefix.<br/>    chart_version = optional(string, "1.9.2")   # Reviewed official Airbyte chart version.<br/>    database = object({<br/>      host                = string                       # External PostgreSQL hostname or service name.<br/>      name                = string                       # Existing PostgreSQL database name.<br/>      port                = optional(number, 5432)       # External PostgreSQL TCP port.<br/>      secret_name         = string                       # Existing Secret containing database credentials.<br/>      user_secret_key     = optional(string, "username") # Username key in database secret.<br/>      password_secret_key = optional(string, "password") # Password key in database secret.<br/>    })<br/>    storage = object({<br/>      bucket                       = string                                   # Existing S3 bucket for Airbyte storage classes.<br/>      region                       = string                                   # AWS region containing the bucket.<br/>      secret_name                  = string                                   # Existing Secret containing S3 credentials.<br/>      access_key_id_secret_key     = optional(string, "s3-access-key-id")     # Access-key ID key in storage secret.<br/>      secret_access_key_secret_key = optional(string, "s3-secret-access-key") # Secret-access-key key in storage secret.<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_dbt"></a> [dbt](#input\_dbt) | Optional dbt runner configuration. Null omits dbt from the platform. | <pre>object({<br/>    name          = optional(string, "dbt-build") # Helm release and dbt CronJob name.<br/>    chart_version = optional(string, "0.1.39")    # Released DasMeta base-cronjob chart version.<br/>    image = object({<br/>      repository  = string                           # Data-product image repository, including registry when applicable.<br/>      tag         = string                           # Immutable data-product image tag.<br/>      pull_policy = optional(string, "IfNotPresent") # Kubernetes image pull policy.<br/>    })<br/>    command                   = list(string)          # Native dbt command and arguments.<br/>    schedule                  = string                # Kubernetes CronJob schedule.<br/>    configuration_secret_name = string                # Existing Secret injected as dbt environment variables.<br/>    configuration_secret_keys = list(string)          # Secret keys injected into the dbt container.<br/>    suspend                   = optional(bool, false) # Suspend future dbt runs while retaining the CronJob.<br/>  })</pre> | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Existing Kubernetes namespace for all selected analytics runtimes. | `string` | n/a | yes |
| <a name="input_postgrest"></a> [postgrest](#input\_postgrest) | Optional PostgREST runtime configuration. Null omits PostgREST from the platform. | <pre>object({<br/>    name                      = optional(string, "postgrest") # Helm release, Deployment, and Service name.<br/>    chart_version             = optional(string, "0.1.0")     # Released DasMeta PostgREST chart version.<br/>    configuration_secret_name = string                        # Existing Secret containing PGRST_* configuration.<br/>    replicas                  = optional(number, 1)           # Number of PostgREST replicas.<br/>  })</pre> | `null` | no |
| <a name="input_visualization"></a> [visualization](#input\_visualization) | Optional visualization runtime. Metabase is the default provider when this object is configured. | <pre>object({<br/>    provider = optional(string, "metabase") # Visualization provider to deploy: metabase or redash.<br/>    metabase = optional(object({<br/>      name                             = optional(string, "metabase") # Helm release, Deployment, and Service name.<br/>      chart_version                    = optional(string, "0.1.0")    # Released DasMeta Metabase chart version.<br/>      application_database_secret_name = string                       # Existing Secret containing MB_DB_CONNECTION_URI.<br/>      replicas                         = optional(number, 1)          # Number of Metabase replicas.<br/>    }))<br/>    redash = optional(object({<br/>      name                      = optional(string, "redash") # Helm release name used for Redash resources.<br/>      chart_version             = optional(string, "0.1.0")  # Released DasMeta Redash chart version.<br/>      configuration_secret_name = string                     # Existing Secret containing required REDASH_* values.<br/>      server_replicas           = optional(number, 1)        # Number of Redash server replicas.<br/>    }))<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_release_statuses"></a> [release\_statuses](#output\_release\_statuses) | Helm-reported release status for selected analytics runtimes. |
| <a name="output_service_endpoints"></a> [service\_endpoints](#output\_service\_endpoints) | Internal HTTP service endpoints for selected long-running analytics runtimes. |
| <a name="output_visualization_provider"></a> [visualization\_provider](#output\_visualization\_provider) | Selected visualization provider, or null when visualization is omitted. |
<!-- END_TF_DOCS -->
