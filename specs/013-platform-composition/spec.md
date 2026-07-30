# Feature Specification: Analytics platform composition module

**Feature Branch**: `013-platform-composition`
**Created**: 2026-07-30
**Status**: In implementation
**Input**: DMVP-10317 and the approved reusable platform architecture.

## Module Context

- **Target Module Path**: `modules/platform`
- **Related Files in Scope**: composition module source, README, complete basic
  example and test fixture, YAML example, repository README, CI module matrix,
  and this feature package.
- **Scope**: a product-level root that composes released, local analytics
  runtime modules. It accepts an existing namespace string and the already
  created service contracts those runtimes need.
- **Explicit exception**: the previous platform plan kept every component in a
  separate root state. The approved product contract now requires one
  platform-root module and one canonical YAML entry point. This module is the
  bounded exception; it does not create or discover shared prerequisites.
- **Out of Scope**: cluster, namespace, Authentik, database instance,
  databases/users/grants, buckets, Redis, Secrets, ingress, DNS, TLS, tenant
  content, dashboards, Airbyte connections, dbt models, PostgREST schemas, or
  Galust configuration.

## User Scenarios & Testing

### User Story 1 — Deploy a selected runtime suite (Priority: P1)

An operator can use one module root to deploy the selected analytics runtimes
into an existing namespace, supplying each runtime's existing database and
Secret references without Terraform receiving secret values.

**Independent Test**: the complete basic fixture initializes and validates
without a Kubernetes cluster or backend.

**Acceptance Scenarios**:

1. Given an existing namespace and all component prerequisites, when an
   operator supplies Airbyte, dbt, and PostgREST configuration, then the
   module composes exactly those component releases.
2. Given a component is omitted (`null`), when the module is planned, then no
   release for that component is created.
3. Given a shared namespace module or Authentik module is used by the caller,
   when its output is passed as `namespace`, then this module consumes only the
   namespace value and creates no cross-repository shared dependency.

### User Story 2 — Choose one visualization runtime (Priority: P1)

An operator can select Metabase (the default provider) or Redash for one
platform instance without deploying both visualization services accidentally.

**Independent Test**: an executable Terraform test rejects an unsupported
provider or a provider whose matching configuration is missing.

**Acceptance Scenarios**:

1. Given `visualization.provider` is omitted and Metabase configuration is
   supplied, when the module is planned, then it selects Metabase.
2. Given `visualization.provider` is `redash` and Redash configuration is
   supplied, when the module is planned, then it selects Redash only.
3. Given both provider configurations or the non-selected provider
   configuration are supplied, when the module is planned, then input
   validation rejects the ambiguous configuration.

### User Story 3 — Consume the module through the existing IaC DSL (Priority: P2)

An operator can copy a single generic `platform.yaml` into a customer IaC
configuration repository, pin a release, and use the existing provisioner to
run its normal Terraform workflow.

**Independent Test**: the YAML example uses only the established
`source`, `version`, and `variables` contract, with no Terraform files or
customer identifiers.

## Functional Requirements

- **FR-001**: The module MUST compose only `airbyte`, `dbt`, `postgrest`, and
  exactly zero or one visualization module from the same repository.
- **FR-002**: The module MUST require an existing namespace and MUST NOT create
  a namespace or reference a shared module by source path.
- **FR-003**: Component configuration MUST be optional as a whole and use
  typed, documented objects that mirror only the component inputs required for
  the supported deployment path.
- **FR-004**: Visualization MUST use a provider selector that defaults to
  Metabase when visualization is configured, allows Redash, and rejects
  ambiguous or unsupported selections.
- **FR-005**: The module MUST expose non-secret internal service endpoints and
  release status only for selected components.
- **FR-006**: The module MUST NOT accept secret values, generic Helm values,
  database-provisioning inputs, ingress, or tenant data-product configuration.
- **FR-007**: README, Terraform example/test, YAML example, repository README,
  and CI matrix MUST describe and validate the same interface.

## Success Criteria

- A generic full-platform Terraform fixture validates with Terraform 1.15.8.
- Invalid or ambiguous visualization input fails before any Helm release is
  planned.
- The YAML example contains no customer-specific names, hostnames, or secrets.
- The composition output has stable internal endpoint objects for only the
  selected runtimes.
