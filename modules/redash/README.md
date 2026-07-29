# Redash Terraform Module

Deploys Redash as the analytics platform's fallback visualization provider.
The module creates Redash's native initialization Job and its official server,
scheduler, scheduled-query worker, ad-hoc-query worker, and default worker
topology. It creates only a private ClusterIP Service.

## Prerequisites

Create the namespace, PostgreSQL database/user/grants, Redis instance, and
configuration Secret before applying this module. The Secret must contain these
keys:

- `REDASH_DATABASE_URL`
- `REDASH_REDIS_URL`
- `REDASH_COOKIE_SECRET`
- `REDASH_SECRET_KEY`

The values are mounted read-only as files. Redash currently has no documented
`_FILE` configuration interface, so the module's minimal wrapper exports the
four values only for the process that then executes Redash's official entrypoint.
Terraform never receives their values.

The initializer runs Redash's native `create_db` command. It owns Redash schema
creation; it does not create a PostgreSQL database, user, grant, Redis instance,
or Kubernetes Secret.

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
| [kubernetes_job_v1.initialize](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job_v1) | resource |
| [kubernetes_service_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_configuration_secret_name"></a> [configuration\_secret\_name](#input\_configuration\_secret\_name) | Existing Secret containing REDASH\_DATABASE\_URL, REDASH\_REDIS\_URL, REDASH\_COOKIE\_SECRET, and REDASH\_SECRET\_KEY keys. | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | Official immutable Redash v26.3.0 multi-architecture container image reference. | `string` | `"redash/redash@sha256:c5c9148f5c389c9373224bde7053b4a1652fd696ee881dce00a064d21ccdcba8"` | no |
| <a name="input_name"></a> [name](#input\_name) | Prefix for Redash workload names and the ClusterIP Service name. | `string` | `"redash"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Existing Kubernetes namespace where Redash is deployed. | `string` | n/a | yes |
| <a name="input_server_replicas"></a> [server\_replicas](#input\_server\_replicas) | Number of Redash server replicas. | `number` | `1` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_server_deployment_name"></a> [server\_deployment\_name](#output\_server\_deployment\_name) | Name of the managed Redash server Deployment. |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | Name of the managed Redash ClusterIP Service. |
| <a name="output_service_port"></a> [service\_port](#output\_service\_port) | HTTP port exposed by the managed Redash ClusterIP Service. |
<!-- END_TF_DOCS -->
