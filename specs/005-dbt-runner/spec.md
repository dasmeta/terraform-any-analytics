# Feature Specification: dbt transformation runner

**Feature Branch**: `005-dbt-runner`
**Created**: 2026-07-29
**Status**: Draft

## Scope

Create `modules/dbt`, a Kubernetes CronJob runner for a data-product-owned dbt
project image. It consumes an existing namespace and a caller-managed Secret
reference; the image owns dbt project files, profiles, and native dbt command
behavior.

The module does not create databases, users, grants, Secrets, dbt models,
packages, sources, schedules outside Kubernetes, ingress, dashboards, or AI
use cases.

## User scenarios

### User Story 1 - Run a tenant-owned dbt project on a schedule (Priority: P1)

An operator can run a published project image with a defined cron schedule and
the native dbt command.

**Independent Test**: Terraform renders a CronJob with the supplied image,
schedule, command, and safe job lifecycle defaults.

### User Story 2 - Keep transformation credentials out of Terraform (Priority: P2)

An operator can inject profile/warehouse credentials through an existing Secret
without exposing values in Terraform input, output, or module documentation.

**Independent Test**: The rendered container uses `envFrom.secretRef` for the
provided Secret name.

### User Story 3 - Run manually when needed (Priority: P3)

An operator can create a one-off Job from the resulting CronJob using normal
Kubernetes controls; the module does not add an imperative runner or job
generation API.

## Requirements

- **FR-001**: Create one `kubernetes_cron_job_v1` in an existing namespace.
- **FR-002**: Require a data-product-owned image, cron schedule, and explicit
  native dbt command list.
- **FR-003**: Require an existing Secret name and inject it only through
  `envFrom.secretRef`.
- **FR-004**: Use `Forbid` concurrency, retain small job history, and set a
  bounded retry default.
- **FR-005**: Do not expose arbitrary pod templates, database connection
  fields, or an unbounded Kubernetes resource pass-through in v1.
- **FR-006**: Include neutral documentation, an example, fixture validation,
  and CI coverage.

## Success criteria

- Module plan contains one CronJob with no credential value.
- Consumers can update their data-product image/command without changing the
  platform module source.
- Manual execution remains Kubernetes-native (`kubectl create job --from=cronjob/...`).
