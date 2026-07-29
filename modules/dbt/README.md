# dbt Terraform Module

Deploys a data-product-owned dbt image through the released DasMeta
`base-cronjob` Helm chart. The image owns its dbt project, models, dependencies,
profiles strategy, and native dbt command. The module owns only scheduling and
lifecycle defaults.

## Prerequisites

Create the namespace and the configuration Secret before applying this module.
List the required Secret keys in `configuration_secret_keys`; the chart injects
only those keys as environment variables, typically for dbt profile and
warehouse credentials. Terraform receives only Secret names and keys, never a
secret value.

The data-product image must already contain the dbt project and all required
packages. This module does not build images, copy project files, or create
database resources.

## Usage

The equivalent YAML IaC DSL reference is
[examples/yaml/dbt.yaml](../../examples/yaml/dbt.yaml).

```hcl
module "dbt" {
  source = "dasmeta/analytics/any//modules/dbt"

  name                      = "example-dbt-build"
  namespace                 = "example-platform"
  image = {
    repository = "registry.example.com/data-products/example-dbt"
    tag        = "1.0.0"
  }
  command                   = ["dbt", "build", "--target", "production"]
  schedule                  = "0 2 * * *"
  configuration_secret_name = "example-dbt-configuration"
  configuration_secret_keys = ["DBT_TARGET", "DBT_USER", "DBT_PASSWORD"]
}
```

The chart version is explicit through `chart_version`. The CronJob forbids
overlapping runs, retries a failed Job once, retains one failed and three
successful Job histories, and can be paused with `suspend`. For a one-off run,
use Kubernetes directly:

```sh
kubectl create job --from=cronjob/example-dbt-build example-dbt-build-manual
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
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Released DasMeta base-cronjob chart version. | `string` | `"0.1.39"` | no |
| <a name="input_command"></a> [command](#input\_command) | Explicit native dbt command and arguments executed by the data-product image. | `list(string)` | n/a | yes |
| <a name="input_configuration_secret_keys"></a> [configuration\_secret\_keys](#input\_configuration\_secret\_keys) | Keys from configuration\_secret\_name injected into the dbt container as environment variables. | `list(string)` | n/a | yes |
| <a name="input_configuration_secret_name"></a> [configuration\_secret\_name](#input\_configuration\_secret\_name) | Existing Secret injected as environment variables for dbt profiles and warehouse credentials. | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | Data-product-owned image used by the native dbt command. | <pre>object({<br/>    repository  = string                           # Data-product image repository, including registry when applicable.<br/>    tag         = string                           # Immutable data-product image tag.<br/>    pull_policy = optional(string, "IfNotPresent") # Kubernetes image pull policy for dbt runs.<br/>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Helm release and dbt CronJob name. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Existing Kubernetes namespace where the dbt CronJob is deployed. | `string` | n/a | yes |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | Kubernetes CronJob schedule for the dbt run. | `string` | n/a | yes |
| <a name="input_suspend"></a> [suspend](#input\_suspend) | When true, keep the CronJob definition but suspend future scheduled dbt runs. | `bool` | `false` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cron_job_name"></a> [cron\_job\_name](#output\_cron\_job\_name) | Name of the dbt CronJob managed by the Helm release. |
| <a name="output_cron_job_namespace"></a> [cron\_job\_namespace](#output\_cron\_job\_namespace) | Namespace of the dbt Helm release. |
| <a name="output_release_status"></a> [release\_status](#output\_release\_status) | Helm-reported dbt release status. |
<!-- END_TF_DOCS -->
