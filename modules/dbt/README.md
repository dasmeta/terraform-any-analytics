# dbt Terraform Module

Creates a Kubernetes CronJob that runs a data-product-owned dbt image. The
image owns its dbt project, models, dependencies, profiles strategy, and native
dbt command. The module owns only Kubernetes scheduling and lifecycle defaults.

## Prerequisites

Create the namespace and the configuration Secret before applying this module.
The Secret is injected as environment variables, typically for dbt profile and
warehouse credentials. Terraform receives only its name, never a secret value.

The data-product image must already contain the dbt project and all required
packages. This module does not build images, copy project files, or create
database resources.

## Usage

```hcl
module "dbt" {
  source = "dasmeta/analytics/any//modules/dbt"

  name                      = "example-dbt-build"
  namespace                 = "example-platform"
  image                     = "registry.example.com/data-products/example-dbt:1.0.0"
  command                   = ["dbt", "build", "--target", "production"]
  schedule                  = "0 2 * * *"
  configuration_secret_name = "example-dbt-configuration"
}
```

The CronJob forbids overlapping runs, retries a failed Job once, retains one
failed and three successful Job histories, and can be paused with `suspend`.
For a one-off run, use Kubernetes directly:

```sh
kubectl create job --from=cronjob/example-dbt-build example-dbt-build-manual
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
| [kubernetes_cron_job_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cron_job_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_command"></a> [command](#input\_command) | Explicit native dbt command and arguments executed by the data-product image. | `list(string)` | n/a | yes |
| <a name="input_configuration_secret_name"></a> [configuration\_secret\_name](#input\_configuration\_secret\_name) | Existing Secret name injected as environment variables for dbt profiles and warehouse credentials. | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | Data-product-owned container image containing the dbt project and runtime. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the dbt Kubernetes CronJob. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Existing Kubernetes namespace where the dbt CronJob is deployed. | `string` | n/a | yes |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | Kubernetes CronJob schedule for the dbt run. | `string` | n/a | yes |
| <a name="input_suspend"></a> [suspend](#input\_suspend) | When true, keep the CronJob definition but suspend future scheduled dbt runs. | `bool` | `false` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cron_job_name"></a> [cron\_job\_name](#output\_cron\_job\_name) | Name of the managed dbt Kubernetes CronJob. |
| <a name="output_cron_job_namespace"></a> [cron\_job\_namespace](#output\_cron\_job\_namespace) | Namespace of the managed dbt Kubernetes CronJob. |
<!-- END_TF_DOCS -->