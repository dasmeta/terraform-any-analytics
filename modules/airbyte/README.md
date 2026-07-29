# Airbyte Terraform Module

Deploys the official Airbyte Helm chart as an ingestion runtime using external
PostgreSQL and AWS S3 storage. The module does not define data sources,
destinations, connections, mappings, or schedules; those are tenant
data-product configuration.

## Scope and prerequisites

The namespace, PostgreSQL database/user/grants, S3 bucket, and Kubernetes
Secrets must already exist. This module never receives or creates credential
values.

The database Secret must contain the configured username and password keys. The
storage Secret must contain the configured S3 access-key and secret-access-key
keys. The module maps one S3 bucket to Airbyte's log, state, activity-payload,
workload-output, and audit-log storage classes.

The official chart creates a native release-local Secret hook. With this module
all credential references point to caller-managed Secrets, so no credential
value is supplied to that hook by Terraform.

The current official chart includes its own Keycloak dependency. It remains
enabled for the chart's supported runtime path; Authentik is the external
ingress proxy. Do not treat this as Airbyte-native SSO integration. External
IdP support requires a separate, officially supported module extension.

## Usage

```hcl
module "airbyte" {
  source = "dasmeta/analytics/any//modules/airbyte"

  namespace = "example-platform"

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
```

Use `webapp_service_name` and `webapp_service_port` as the backend in the
separately managed ingress setup. This module intentionally has no hostname,
DNS, TLS, or ingress input.

## Operations

The chart version is explicit through `chart_version`. Review upstream release
notes and migrations before changing it. Helm uses atomic operations, cleans up
failed fresh installs, waits for readiness, and uses a 15-minute timeout.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Reviewed version of the official Airbyte Helm chart. | `string` | `"1.9.2"` | no |
| <a name="input_database"></a> [database](#input\_database) | External PostgreSQL endpoint metadata and an existing Secret reference for the Airbyte database credentials. | <pre>object({<br/>    host                = string                       # External PostgreSQL hostname or service name.<br/>    name                = string                       # Existing PostgreSQL database name.<br/>    port                = optional(number, 5432)       # External PostgreSQL TCP port.<br/>    secret_name         = string                       # Existing Secret containing database credentials.<br/>    user_secret_key     = optional(string, "username") # Key holding the database username in secret_name.<br/>    password_secret_key = optional(string, "password") # Key holding the database password in secret_name.<br/>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Helm release name and prefix for derived Airbyte resource names. | `string` | `"airbyte"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Existing Kubernetes namespace where Airbyte is deployed. | `string` | n/a | yes |
| <a name="input_storage"></a> [storage](#input\_storage) | Existing AWS S3 storage contract and a Secret reference for Airbyte credentials. | <pre>object({<br/>    bucket                       = string                                   # Existing S3 bucket used for all Airbyte storage classes.<br/>    region                       = string                                   # AWS region containing bucket.<br/>    secret_name                  = string                                   # Existing Secret containing S3 credentials.<br/>    access_key_id_secret_key     = optional(string, "s3-access-key-id")     # Key holding the S3 access key ID in secret_name.<br/>    secret_access_key_secret_key = optional(string, "s3-secret-access-key") # Key holding the S3 secret access key in secret_name.<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_release_chart_version"></a> [release\_chart\_version](#output\_release\_chart\_version) | Chart version used by the Airbyte Helm release. |
| <a name="output_release_name"></a> [release\_name](#output\_release\_name) | Name of the Airbyte Helm release. |
| <a name="output_release_namespace"></a> [release\_namespace](#output\_release\_namespace) | Namespace of the Airbyte Helm release. |
| <a name="output_release_status"></a> [release\_status](#output\_release\_status) | Helm-reported Airbyte release status. |
| <a name="output_webapp_service_name"></a> [webapp\_service\_name](#output\_webapp\_service\_name) | Internal Airbyte webapp Service name for separately managed ingress. |
| <a name="output_webapp_service_port"></a> [webapp\_service\_port](#output\_webapp\_service\_port) | Internal Airbyte webapp Service HTTP port for separately managed ingress. |
<!-- END_TF_DOCS -->