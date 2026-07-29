# Feature Specification: Default Metabase Visualization Module

**Feature Branch**: `009-metabase-module`
**Created**: 2026-07-29
**Status**: Complete

## User Scenarios & Testing

### User Story 1 - Deploy the default visualization provider (Priority: P1)

An operator deploys a production-ready Metabase instance into an existing analytics namespace and supplies only the pre-created application database Secret.

**Why this priority**: Metabase is the platform's default visualization provider.

**Independent Test**: Terraform validation and a no-change plan succeed using a name, namespace, and existing Secret reference; the rendered resources contain one Deployment and one ClusterIP Service.

**Acceptance Scenarios**:

1. **Given** an existing namespace and application-database Secret, **When** the module is applied, **Then** it creates Metabase and exposes it only through a ClusterIP Service on port 3000.
2. **Given** the Secret contains the documented `MB_DB_CONNECTION_URI` key, **When** Metabase starts, **Then** it uses external PostgreSQL rather than the embedded H2 database.

### User Story 2 - Preserve platform boundaries (Priority: P2)

An operator can use the module without it creating a database, credentials, ingress, dashboards, or identity-provider configuration.

**Why this priority**: Database, ingress, Authentik, and data-product content have separate ownership.

**Independent Test**: Source inspection verifies no database, Secret, Ingress, dashboard, or Authentik resources are declared.

**Acceptance Scenarios**:

1. **Given** a consumer configures the module, **When** it is planned, **Then** Terraform reads only the supplied existing Secret name and does not create sensitive data.

### Edge Cases

- A missing or malformed database Secret prevents a healthy Metabase start; the module documentation names the required keys.
- Metabase upgrades require a controlled single-replica migration window; the module defaults to one replica and documents this operational constraint.

## Requirements

### Functional Requirements

- **FR-001**: The module MUST deploy the official Metabase Open Source image pinned by immutable digest.
- **FR-002**: The module MUST mount an existing Kubernetes Secret key as a file and use Metabase's documented `MB_DB_CONNECTION_URI_FILE` configuration, avoiding database credentials in environment metadata.
- **FR-003**: The module MUST create a ClusterIP Service on port 3000 and MUST NOT create ingress.
- **FR-004**: The module MUST default to one replica and apply constrained resources, non-root execution, dropped Linux capabilities, and no service-account token mounting.
- **FR-005**: The module MUST include an executable example, Terraform test fixtures, documentation, and module validation workflow coverage.
- **FR-006**: The module MUST document that dashboard content, data-source registration, and Authentik forward-auth are outside this module.

### Key Entities

- **Metabase deployment**: The default BI application workload.
- **Application database Secret**: Pre-created Secret containing Metabase's external PostgreSQL connection URI.
- **Metabase service**: Private ClusterIP endpoint used by gateway/ingress configuration outside the module.

## Success Criteria

- **SC-001**: A consumer can configure the module with three required inputs: namespace, application-database Secret name, and optional service name.
- **SC-002**: `terraform fmt -check`, `terraform validate`, and a no-change example plan succeed.
- **SC-003**: The default module plan creates only a Deployment and ClusterIP Service, apart from provider-managed metadata.

## Assumptions

- A separate platform layer creates the PostgreSQL database, user, grants, Secret, namespace, gateway/ingress, and Authentik resources.
- The application database Secret provides `MB_DB_CONNECTION_URI` as a complete PostgreSQL JDBC connection URI.
- Authentik protects browser access at the gateway/ingress layer; Metabase native SSO is not configured by this module.
