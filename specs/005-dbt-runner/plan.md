# Implementation Plan: dbt transformation runner

**Branch**: `005-dbt-runner` | **Date**: 2026-07-29 | **Spec**: [spec.md](spec.md)

## Design

Use `kubernetes_cron_job_v1` directly. dbt has no official Helm runtime that
would improve this narrow single-workload capability, and the provider-managed
CronJob is the bounded direct-resource fallback.

The platform module owns Kubernetes scheduling only. A tenant data product owns
the image, its dbt project, `profiles.yml` strategy, package lock, models, and
the explicit native dbt command. An external Secret is injected with `envFrom`;
the module never receives connection values.

## Interface

- `name`, `namespace`: CronJob identity and existing deployment boundary.
- `image`, `command`, `schedule`: immutable data-product runtime selection.
- `configuration_secret_name`: existing Secret with dbt profile/warehouse
  environment values.
- `suspend`: controlled pause without deleting the CronJob.

The module deliberately does not accept arbitrary pod specs, volume mounts,
resource maps, database settings, model source, or a broad Kubernetes
pass-through. Such needs must be a separately reviewed extension.

## Modern capability classification

- `kubernetes_cron_job_v1`: supported modern Kubernetes provider resource.
- `batch/v1` CronJob: supported Kubernetes API.
- Imperative Terraform `Job` creation: replaced by scheduled CronJob plus
  Kubernetes-native one-off Job creation.

## Validation

Format, initialize and validate a no-backend fixture, run a no-apply plan, and
confirm the plan contains the Secret reference but no secret value. Include the
module in the existing Terraform validation workflow.
