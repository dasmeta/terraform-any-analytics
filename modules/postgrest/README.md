# PostgREST Terraform Module

Deploys official PostgREST as an internal API runtime through the released
DasMeta `postgrest` Helm chart over an externally prepared PostgreSQL API
schema.

The namespace, database, authenticator role, grants, API schemas/views,
functions, and configuration Secret must exist before applying the module. The
Secret must contain native `PGRST_*` settings, including `PGRST_DB_URI`,
`PGRST_DB_SCHEMAS`, `PGRST_DB_ANON_ROLE`, and a JWT verification setting such as
`PGRST_JWT_SECRET`. Terraform never receives those values.

The module creates only a Helm release and private ClusterIP Service. Configure
ingress, DNS, Authentik proxy policy, and Galust access separately using
`service_name` and `service_port`. The chart version is explicit through
`chart_version`.

## Usage

```hcl
module "postgrest" {
  source = "dasmeta/analytics/any//modules/postgrest"

  namespace                 = "example-platform"
  configuration_secret_name = "postgrest-configuration"
}
```

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
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Released DasMeta PostgREST chart version. | `string` | `"0.1.0"` | no |
| <a name="input_configuration_secret_name"></a> [configuration\_secret\_name](#input\_configuration\_secret\_name) | Existing Secret containing PGRST\_* database, schema, role, and JWT configuration variables. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Helm release, Deployment, and ClusterIP Service name. | `string` | `"postgrest"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Existing Kubernetes namespace where PostgREST is deployed. | `string` | n/a | yes |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of PostgREST replicas. | `number` | `1` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_release_status"></a> [release\_status](#output\_release\_status) | Helm-reported PostgREST release status. |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | PostgREST ClusterIP Service name. |
| <a name="output_service_port"></a> [service\_port](#output\_service\_port) | PostgREST ClusterIP Service HTTP port. |
<!-- END_TF_DOCS -->
