# Feature Specification: Airbyte ingestion module

**Feature Branch**: `003-airbyte-module`
**Created**: 2026-07-29
**Status**: Draft
**Input**: Implement the reusable Airbyte runtime for the analytics platform.

## Scope

Create `modules/airbyte`, a narrow wrapper for the official Airbyte chart. It
uses an existing namespace, external PostgreSQL database credentials referenced
by an existing Kubernetes Secret, and an external AWS S3 bucket with credentials
referenced by another existing Secret.

The module does not create a namespace, database, database user/grants,
Kubernetes Secret, object bucket, ingress, DNS record, Airbyte source,
destination, connection, schedule, or sync job.

## User Scenarios & Testing

### User Story 1 - Deploy a reusable ingestion runtime (Priority: P1)

An operator can deploy the Airbyte UI and worker runtime without allowing the
chart to create PostgreSQL or object storage.

**Independent Test**: A Terraform plan and Helm render show external database
and S3 configuration, disabled bundled PostgreSQL and MinIO, and no credential
values in Terraform.

**Acceptance Scenarios**:

1. **Given** pre-existing database and S3 contracts, **when** the module is
   applied, **then** it deploys the official Airbyte release without creating
   PostgreSQL or MinIO resources.
2. **Given** caller-managed Secret references, **when** the release is
   rendered, **then** database and S3 credentials use `secretKeyRef` rather
   than Terraform-supplied values.

### User Story 2 - Publish through the standard ingress (Priority: P2)

An operator can expose Airbyte through the cluster's existing ingress and
Authentik proxy configuration without this module owning either concern.

**Independent Test**: The module returns deterministic webapp Service details.

### User Story 3 - Record the identity exception (Priority: P3)

The module documents that the current official chart embeds Keycloak and does
not expose a stable external-IdP contract suitable for the generic module.

**Independent Test**: Module documentation and values keep the upstream
identity dependency explicit; Authentik remains the ingress boundary until a
supported Airbyte external-IdP contract is selected.

## Requirements

- **FR-001**: Use the official Airbyte chart repository and default chart
  version `1.9.2`.
- **FR-002**: Force external PostgreSQL and disable the chart's PostgreSQL
  subchart.
- **FR-003**: Support AWS S3 only in v1; use one caller-owned bucket for all
  Airbyte storage classes and an existing Secret for credentials.
- **FR-004**: Set storage type to S3, so the chart does not render MinIO.
- **FR-005**: Require existing Secret names and keys for database user/password
  and S3 access key/secret key; never accept secret values.
- **FR-006**: Enable the webapp with an internal ClusterIP Service and output
  its deterministic name/port for separate ingress.
- **FR-007**: Do not disable or configure the chart's internal Keycloak in v1;
  record it as an upstream dependency and use Authentik at ingress.
- **FR-008**: Use atomic, waiting Helm operations, cleanup on failed fresh
  install, and a documented timeout.
- **FR-009**: Provide README, example, validation fixture, and CI coverage.

## Success Criteria

- A plan can be produced with no secret value in the Terraform interface.
- A Helm render contains no PostgreSQL or MinIO StatefulSet.
- The rendered workloads reference the supplied database and S3 Secret names.
- The output endpoint is usable by a separately owned ingress setup.
