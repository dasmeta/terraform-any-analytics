<p align="center">
  <a href="https://www.dasmeta.com">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://a.storyblok.com/f/295271/424783ac50/dasmeta-wordmark-light.png">
      <source media="(prefers-color-scheme: light)" srcset="https://a.storyblok.com/f/295271/5938d2b888/dasmeta-wordmark-dark.png">
      <img src="https://a.storyblok.com/f/295271/5938d2b888/dasmeta-wordmark-dark.png" alt="Das Meta" width="220">
    </picture>
  </a>
</p>

# terraform-any-analytics

The Terraform root module composes a selected analytics-platform runtime suite
into an existing Kubernetes namespace using version-pinned Helm charts. The
individual runtime modules remain available below `modules/` when independent
state or release cadence is required.

**Current delivery state (verified 2026-07-30):** component modules were
released as `v1.0.0`. The platform composition module introduced after that
release must be pinned to the next published version before its YAML example is
applied.

**Compatibility:** Terraform `~> 1.3` and the HashiCorp Helm provider `~> 3.0`.
Each module requires an existing Kubernetes namespace and a configured Helm
provider context.

## Which analytics runtime should I use?

Use the platform module for the standard, one-entry-point runtime suite. Use
individual component modules where a component must retain independent state or
release cadence.

| Module | Use it for | Runtime dependency owned outside this module |
| --- | --- | --- |
| [Platform root](./) | opinionated composition of selected analytics runtimes | namespace, Authentik, databases/users/grants, buckets, Redis, Secrets, ingress, DNS, and tenant content |
| [Airbyte](./modules/airbyte/) | ingesting data with the official Airbyte Helm chart | PostgreSQL, S3 bucket, and database/storage Secrets |
| [dbt](./modules/dbt/) | scheduling a data-product-owned dbt image | configuration Secret and the image's dbt project and warehouse access |
| [PostgREST](./modules/postgrest/) | exposing a prepared PostgreSQL schema as an internal API | database roles, grants, API schema/views/functions, and `PGRST_*` Secret |
| [Metabase](./modules/metabase/) | the default visualization provider | PostgreSQL application database, user/grants, and connection Secret |
| [Redash](./modules/redash/) | a fallback visualization provider | PostgreSQL, Redis, and configuration Secret |

Metabase and Redash are alternatives for visualization; the platform module
enforces one selected provider. Airbyte and dbt do not configure source
connections, transformations, models, mappings, or schedules beyond the dbt
command and CronJob schedule provided to the module.

## What does this repository manage?

Each selected runtime child module creates its own `helm_release` and, where
its chart provides one, a private ClusterIP service or CronJob. The composition
root creates no direct Helm release or Kubernetes resource. The caller provides
the surrounding platform contracts:

1. Provision the namespace, databases, users, grants, storage, Redis, and
   Kubernetes Secrets through the platform's database and secrets layers.
2. Configure the Helm provider for the target cluster, then instantiate the
   selected module roots.
3. Configure Gateway/ingress, DNS, TLS, Authentik policy, and Galust access
   separately using the service outputs exposed by the relevant module.
4. Configure tenant data-product content in its native tool: Airbyte sources
   and connections, dbt models, PostgREST API schema, and visualization users,
   queries, and dashboards.

Terraform receives Secret names and key names only. It does not create or store
credential values.

## Platform root usage

The repository root is the standard one-entry-point module. It composes
optional Airbyte, dbt, and PostgREST runtimes, plus exactly one visualization
provider.

```hcl
module "analytics_platform" {
  source = "dasmeta/analytics/any"

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

`airbyte`, `dbt`, `postgrest`, and `visualization` are optional. Omit a
component or set it to `null` to exclude it. When `visualization` is present,
Metabase is the default provider; set `provider = "redash"` with only a
`redash` configuration to select Redash. The root rejects unknown, missing, or
ambiguous visualization selections.

The root accepts no generic Helm-values escape hatch. Namespace, Authentik,
database infrastructure, database users/grants, buckets, Redis, Secrets,
Gateway/ingress, DNS, TLS, and tenant data-product content remain in their
respective owners and are passed here only through documented non-secret
references.

## How do I evaluate a module before a release is published?

The repository's verified local check validates each basic module fixture
without a Kubernetes cluster or backend:

```sh
terraform fmt -check -recursive

for module in . modules/airbyte modules/dbt modules/postgrest modules/metabase modules/redash; do
  terraform -chdir="$module/tests/basic" init -backend=false
  terraform -chdir="$module/tests/basic" validate
done
```

The GitHub Actions workflow runs the same `init -backend=false` and `validate`
steps with Terraform 1.15.8. Validation checks module syntax and provider
contracts; it does not install a chart or prove that caller-managed runtime
dependencies exist.

For the standard suite, start with the [platform basic
example](./examples/basic/). For a
component-specific configuration, start with its [basic
example](./modules/airbyte/examples/basic/). All examples expect
caller-managed prerequisites and do not contain production credentials.

## Can I use the YAML examples in a customer IaC repository?

Yes, as reference configurations. The [platform YAML
example](./examples/yaml/platform.yaml) is the canonical one-entry-point
configuration and uses the established DasMeta `source`, `version`, and
`variables` shape. Copy it to the customer's IaC configuration repository,
replace `<released-platform-version>` after release, and retain the customer
repository's provider, remote-state, and linked-Setup configuration. Individual
component examples remain available for intentionally separate states.

The YAML files are not Kubernetes manifests and do not replace the Terraform
examples. They deliberately reference existing Secrets by name and use neutral
example values.

## What is intentionally out of scope?

These modules do not:

- provision Kubernetes namespaces, databases, database users, grants, buckets,
  Redis, or credential values;
- configure Gateway/ingress, DNS, TLS, or Authentik forward-auth;
- create Airbyte sources, destinations, connections, mappings, or schedules;
- build dbt images or copy dbt projects into containers;
- define PostgREST database schemas, roles, grants, views, or functions; or
- create Metabase or Redash users, data sources, queries, dashboards, alerts,
  or email configuration.

Use the owning platform layer or the native application for those concerns.

## Where is the canonical documentation for each concern?

| Question | Canonical location |
| --- | --- |
| Repository purpose, module selection, boundaries, and validated entry point | this README |
| Standard suite interface and selected component endpoints | this README |
| Component inputs, outputs, chart versions, operational notes, and service names | the relevant [component README](./modules/) |
| Terraform configuration shape | each module's [basic example](./modules/airbyte/examples/basic/) |
| Customer IaC DSL shape | [YAML examples](./examples/yaml/) |
| Executable validation contract | [basic tests](./modules/) and [Terraform validation workflow](./.github/workflows/terraform-test.yaml) |
| License terms | [Apache License 2.0](./LICENSE) |

This repository currently has no published `CONTRIBUTING.md`, `SECURITY.md`,
`SUPPORT.md`, or `CHANGELOG.md`. Repository-owner confirmation is required
before claiming a contribution process, security-reporting route, support SLA,
or release-versioning policy.

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
| <a name="module_airbyte"></a> [airbyte](#module\_airbyte) | ./modules/airbyte | n/a |
| <a name="module_dbt"></a> [dbt](#module\_dbt) | ./modules/dbt | n/a |
| <a name="module_metabase"></a> [metabase](#module\_metabase) | ./modules/metabase | n/a |
| <a name="module_postgrest"></a> [postgrest](#module\_postgrest) | ./modules/postgrest | n/a |
| <a name="module_redash"></a> [redash](#module\_redash) | ./modules/redash | n/a |

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

---

<p align="center">
  Created by <a href="https://github.com/dasmeta">DasMeta</a> ·
  <a href="https://github.com/dasmeta/terraform-any-analytics/issues">Issues</a> ·
  <a href="./LICENSE">Apache-2.0 License</a>
</p>
