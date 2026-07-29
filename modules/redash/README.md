# Redash Terraform Module

Deploys Redash as the analytics platform's fallback visualization provider
through the released DasMeta `redash` Helm chart. The chart creates Redash's
native initialization flow and its official server, scheduler, scheduled-query
worker, ad-hoc-query worker, and default worker topology. It creates only a
private ClusterIP Service.

## Prerequisites

Create the namespace, PostgreSQL database/user/grants, Redis instance, and
configuration Secret before applying this module. The Secret must contain these
keys:

- `REDASH_DATABASE_URL`
- `REDASH_REDIS_URL`
- `REDASH_COOKIE_SECRET`
- `REDASH_SECRET_KEY`

The released chart injects the Secret into each native Redash process.
Terraform never receives its values.

The server init container runs Redash's native `create_db` command. It owns
Redash schema creation; it does not create a PostgreSQL database, user, grant,
Redis instance, or Kubernetes Secret.

## Usage

```hcl
module "redash" {
  source = "dasmeta/analytics/any//modules/redash"

  namespace                 = "example-platform"
  configuration_secret_name = "redash-configuration"
}
```

Gateway/ingress, TLS, and Authentik forward-auth are configured outside this
module. Native Redash users, data sources, queries, dashboards, alerts, and
email are tenant data-product content and remain outside the module contract.
The chart version is explicit through `chart_version`; the server Service name
is `<release-name>-redash-server`.

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
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Released DasMeta Redash chart version. | `string` | `"0.1.0"` | no |
| <a name="input_configuration_secret_name"></a> [configuration\_secret\_name](#input\_configuration\_secret\_name) | Existing Secret containing REDASH\_DATABASE\_URL, REDASH\_REDIS\_URL, REDASH\_COOKIE\_SECRET, and REDASH\_SECRET\_KEY. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Helm release name used to derive Redash component resource names. | `string` | `"redash"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Existing Kubernetes namespace where Redash is deployed. | `string` | n/a | yes |
| <a name="input_server_replicas"></a> [server\_replicas](#input\_server\_replicas) | Number of Redash server replicas. | `number` | `1` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_release_status"></a> [release\_status](#output\_release\_status) | Helm-reported Redash release status. |
| <a name="output_server_deployment_name"></a> [server\_deployment\_name](#output\_server\_deployment\_name) | Name of the Redash server Deployment. |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | Name of the Redash server ClusterIP Service. |
| <a name="output_service_port"></a> [service\_port](#output\_service\_port) | HTTP port exposed by the Redash server ClusterIP Service. |
<!-- END_TF_DOCS -->
