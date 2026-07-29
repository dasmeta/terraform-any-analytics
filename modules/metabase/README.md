# Metabase Terraform Module

Deploys Metabase Open Source as the analytics platform's default visualization
provider. The module creates a hardened Kubernetes Deployment and private
ClusterIP Service; it uses an external PostgreSQL application database rather
than Metabase's embedded H2 database.

## Prerequisites

Create the namespace, PostgreSQL application database, database user/grants,
and configuration Secret before applying this module. The module accepts only
the existing Secret name, never database credentials or connection values.

The Secret must provide this key:

- `MB_DB_CONNECTION_URI`: a complete PostgreSQL JDBC connection URI

The module mounts this value as a file and sets Metabase's documented
`MB_DB_CONNECTION_URI_FILE` variable; it does not inject database credentials
into the pod environment. `MB_DB_TYPE=postgres` is set by the module. Metabase
owns its own application-database schema migrations. The database itself,
user/grants, and Secret are owned by the platform database/secrets composition
layer.

## Usage

```hcl
module "metabase" {
  source = "dasmeta/analytics/any//modules/metabase"

  namespace                       = "example-platform"
  application_database_secret_name = "metabase-application-database"
}
```

The module exposes Metabase only through a ClusterIP Service on port 3000.
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
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_deployment_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1) | resource |
| [kubernetes_service_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_application_database_secret_name"></a> [application\_database\_secret\_name](#input\_application\_database\_secret\_name) | Existing Secret containing the MB\_DB\_CONNECTION\_URI key for Metabase's external PostgreSQL application database. | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | Official immutable Metabase Open Source v0.63.1.12 container image reference. | `string` | `"metabase/metabase@sha256:a6e4100e913165ab2f2d5ac36bc1a2f63edd0ff5b2292e7a10642351598e1de7"` | no |
| <a name="input_name"></a> [name](#input\_name) | Deployment and ClusterIP Service name. | `string` | `"metabase"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Existing Kubernetes namespace where Metabase is deployed. | `string` | n/a | yes |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of Metabase replicas; retain one replica during application database migrations. | `number` | `1` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_deployment_name"></a> [deployment\_name](#output\_deployment\_name) | Name of the managed Metabase Deployment. |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | Name of the managed Metabase ClusterIP Service. |
| <a name="output_service_port"></a> [service\_port](#output\_service\_port) | HTTP port exposed by the managed Metabase ClusterIP Service. |
<!-- END_TF_DOCS -->
