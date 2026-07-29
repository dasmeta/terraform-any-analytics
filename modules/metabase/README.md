# Metabase Terraform Module

Deploys Metabase Open Source as the analytics platform's default visualization
provider through the released DasMeta `metabase` Helm chart. It uses an external
PostgreSQL application database rather than Metabase's embedded H2 database.

## Prerequisites

Create the namespace, PostgreSQL application database, database user/grants,
and configuration Secret before applying this module. The module accepts only
the existing Secret name, never database credentials or connection values.

The Secret must provide this key:

- `MB_DB_CONNECTION_URI`: a complete PostgreSQL JDBC connection URI

The released chart injects this Secret as runtime environment variables and the
module sets `MB_DB_TYPE=postgres`. Metabase owns its own application-database
schema migrations. The database itself, user/grants, and Secret are owned by the
platform database/secrets composition layer.

## Usage

The equivalent YAML IaC DSL reference is
[examples/yaml/metabase.yaml](../../examples/yaml/metabase.yaml).

```hcl
module "metabase" {
  source = "dasmeta/analytics/any//modules/metabase"

  namespace                       = "example-platform"
  application_database_secret_name = "metabase-application-database"
}
```

The module exposes Metabase only through a ClusterIP Service on port 3000. The
chart version is explicit through `chart_version`.
Gateway/ingress, TLS, and Authentik forward-auth are configured outside this
module. Native Metabase initial setup, data-source registration, collections,
and dashboards are data-product content and are also out of scope.

Metabase defaults to one replica. During upgrades, retain one replica while
Metabase applies its application-database migrations; scale only according to a
documented upgrade procedure.

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
| <a name="input_application_database_secret_name"></a> [application\_database\_secret\_name](#input\_application\_database\_secret\_name) | Existing Secret containing the MB\_DB\_CONNECTION\_URI value for Metabase's external PostgreSQL application database. | `string` | n/a | yes |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Released DasMeta Metabase chart version. | `string` | `"0.1.0"` | no |
| <a name="input_name"></a> [name](#input\_name) | Helm release, Deployment, and ClusterIP Service name. | `string` | `"metabase"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Existing Kubernetes namespace where Metabase is deployed. | `string` | n/a | yes |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of Metabase replicas; retain one replica during application database migrations. | `number` | `1` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_deployment_name"></a> [deployment\_name](#output\_deployment\_name) | Metabase Deployment name rendered by the component chart. |
| <a name="output_release_status"></a> [release\_status](#output\_release\_status) | Helm-reported Metabase release status. |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | Metabase ClusterIP Service name. |
| <a name="output_service_port"></a> [service\_port](#output\_service\_port) | Metabase ClusterIP Service HTTP port. |
<!-- END_TF_DOCS -->
