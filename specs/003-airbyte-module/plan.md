# Implementation Plan: Airbyte ingestion module

**Branch**: `003-airbyte-module` | **Date**: 2026-07-29 | **Spec**: [spec.md](spec.md)

## Technical approach

Implement `modules/airbyte` as a direct, strict `helm_release` wrapper around
the official Airbyte chart `1.9.2`. No provider-maintained Terraform module
exists for Airbyte, making the direct wrapper the bounded fallback.

The module supports the common v1 runtime: an existing namespace, external
PostgreSQL, and AWS S3. It maps one S3 bucket to Airbyte's log, state, activity,
workload-output, and audit-log storage classes. This avoids provisioning
MinIO—the chart renders a MinIO StatefulSet only when storage type is `minio`.

Database and S3 credentials are references only. The Airbyte chart still
creates its native release-local Secret hook, but no credential values are
supplied to it when the module uses external Secret references.

## Upstream findings and decisions

1. The official chart is published at `https://airbytehq.github.io/helm-charts`
   as `airbyte` version `1.9.2` (app version `2.0.2-alpha-c905e75`). Pin the
   chart version; upgrades are explicit.
2. `global.database` supports an external host, port, database, and a Secret
   with `userSecretKey` and `passwordSecretKey`; set `postgresql.enabled=false`.
3. `global.storage.type=s3` prevents the chart's MinIO StatefulSet. S3
   credentials use a supplied Secret and configured key names.
4. The chart enables internal Keycloak by default. The published chart values
   do not provide a stable generic external-IdP interface. Keep it as an
   explicitly documented service-native dependency; Authentik protects the
   external ingress boundary. Revisit only with official external-IdP evidence.
5. Do not expose an arbitrary Helm-values object. Resource tuning, custom
   connector configuration, advanced storage providers, and identity changes
   are future reviewed extensions.

## Interface

| Input | Purpose |
|---|---|
| `name`, `namespace`, `chart_version` | Release identity and placement. |
| `database` | Non-secret external PostgreSQL endpoint plus Secret reference/keys. |
| `storage` | S3 bucket/region plus Secret reference/keys. |

| Output | Purpose |
|---|---|
| `release_*` | Helm release identity, status, version. |
| `webapp_service_*` | Internal web UI endpoint for separate ingress. |

## Validation

1. Format all module artifacts.
2. Initialize and validate a no-backend Terraform fixture.
3. Run a no-apply Terraform plan.
4. Render and lint the official chart with equivalent external database/S3
   values; confirm existing Secret references and no PostgreSQL/MinIO
   StatefulSet.
5. Run available static checks and record unavailable local tooling.

## Modern capability classification

- `helm_release` with Helm provider `~> 3.0`: supported.
- Chart external database Secret references: supported.
- Chart S3 storage Secret references: supported.
- Chart-internal MinIO: replaced by external S3 for this platform module.
- External application IdP: out of scope pending official stable chart support.
