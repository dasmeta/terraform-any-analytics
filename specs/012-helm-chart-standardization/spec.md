# Feature Specification: Helm-only Analytics Workloads

**Feature Branch**: `012-helm-chart-standardization`
**Created**: 2026-07-29
**Status**: In progress

## Requirements

- **FR-001**: Terraform MUST manage application workloads only through `helm_release`, never through Kubernetes workload, Job, Service, or CronJob resources.
- **FR-002**: dbt MUST use the released DasMeta `base-cronjob` chart v0.1.39.
- **FR-003**: PostgREST, Metabase, and Redash MUST use the released DasMeta component charts v0.1.0.
- **FR-004**: Airbyte and Authentik remain on their upstream Helm charts.
- **FR-005**: Existing external Secret, database, Redis, ingress, Authentik, and data-product ownership boundaries remain unchanged.
- **FR-006**: Redash MUST retain its native `create_db` initialization through the Redash chart's server init-container mechanism.
- **FR-007**: Modules MUST use published, version-pinned charts in normal operation; branch or filesystem chart sources are excluded from the reusable production interface.
- **FR-008**: Each affected module MUST include a maintained README, a basic example, and a Terraform validation test using only the Helm provider.
- **FR-009**: The repository MUST include secret-reference-only YAML IaC DSL examples for each analytics component, alongside the Terraform examples.

## Success Criteria

- **SC-001**: The four corrected modules declare only `helm_release` resources and Helm provider requirements.
- **SC-002**: Formatting, Terraform validation, and Helm rendering of the released chart values pass.
- **SC-003**: No local Helm chart or Kubernetes manifest is introduced in `terraform-any-analytics`.
- **SC-004**: YAML examples use the established `source`, `version`, and `variables` structure and do not contain credentials or client-specific values.
