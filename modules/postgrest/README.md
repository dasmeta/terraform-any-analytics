# PostgREST Terraform Module

Deploys official PostgREST as an internal Kubernetes API runtime over an
externally prepared PostgreSQL API schema.

The namespace, database, authenticator role, grants, API schemas/views,
functions, and configuration Secret must exist before applying the module. The
Secret must contain a `postgrest.conf` file with `db-uri` and a valid JWT/JWK
verification configuration such as `jwt-secret`; it is mounted read-only and
Terraform never receives those values.

The module creates only a Deployment and ClusterIP Service. Configure ingress,
DNS, Authentik proxy policy, and Galust access separately using `service_name`
and `service_port`.

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
| <a name="input_configuration_secret_name"></a> [configuration\_secret\_name](#input\_configuration\_secret\_name) | Existing Secret containing a postgrest.conf configuration file with database and JWT/JWK verification settings. | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | Official immutable PostgREST v13.0.8 container image reference. | `string` | `"postgrest/postgrest@sha256:d09618df2b7b9547c80a076c2f4045b326be8d7ac06060d263caefec1334e3c9"` | no |
| <a name="input_name"></a> [name](#input\_name) | Deployment and ClusterIP Service name. | `string` | `"postgrest"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Existing Kubernetes namespace where PostgREST is deployed. | `string` | n/a | yes |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of PostgREST replicas. | `number` | `1` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | Internal PostgREST ClusterIP Service name. |
| <a name="output_service_namespace"></a> [service\_namespace](#output\_service\_namespace) | Namespace of the PostgREST Service. |
| <a name="output_service_port"></a> [service\_port](#output\_service\_port) | Internal PostgREST HTTP Service port. |
<!-- END_TF_DOCS -->
