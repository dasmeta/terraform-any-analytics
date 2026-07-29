# Feature Specification: Redash Fallback Visualization Module

**Feature Branch**: `011-redash-module`
**Created**: 2026-07-29
**Status**: Complete

## User Scenarios & Testing

### User Story 1 - Deploy the fallback visualization provider (Priority: P1)

An operator deploys a complete Redash runtime into an existing analytics namespace using pre-created PostgreSQL, Redis, and configuration Secret interfaces.

**Independent Test**: Terraform validation and a no-change plan render a database-initialization Job, the official server/scheduler/worker topology, and one ClusterIP Service.

**Acceptance Scenarios**:

1. **Given** an existing namespace and configuration Secret, **When** the module is applied, **Then** it initializes the Redash schema and starts server, scheduler, scheduled-query, ad-hoc-query, and default workers.
2. **Given** an operator needs browser access, **When** the module is planned, **Then** it exposes only a ClusterIP Service on port 5000.

### User Story 2 - Preserve component and platform boundaries (Priority: P2)

The Redash module uses native Redash commands but does not create PostgreSQL, Redis, Secrets, ingress, Authentik resources, or dashboard content.

**Independent Test**: Source inspection shows only Kubernetes Job, Deployment, and Service resources, and configuration values are mounted as files.

## Requirements

- **FR-001**: Use the official Redash v26.3.0 image pinned by immutable multi-architecture digest.
- **FR-002**: Create a native `create_db` Job before runtime workloads start.
- **FR-003**: Create the Redash server, scheduler, scheduled-query worker, ad-hoc-query worker, and default worker according to the official setup topology.
- **FR-004**: Consume existing Secret files named `REDASH_DATABASE_URL`, `REDASH_REDIS_URL`, `REDASH_COOKIE_SECRET`, and `REDASH_SECRET_KEY`; do not inject credentials as environment variables.
- **FR-005**: Create only a ClusterIP Service on port 5000, with no ingress.
- **FR-006**: Add documentation, executable example, Terraform tests, and CI validation coverage.

## Success Criteria

- **SC-001**: A valid module plan creates one Job, five Deployments, and one ClusterIP Service.
- **SC-002**: `terraform fmt -check`, `terraform validate`, example plan, and Checkov pass.
- **SC-003**: No Redash Secret value is exposed in Terraform configuration or pod environment metadata.

## Assumptions

- Platform composition owns the namespace, PostgreSQL database/user/grants, Redis instance, configuration Secret, gateway/ingress, TLS, and Authentik.
- The configuration Secret contains full connection URLs and stable shared Redash cookie/data-source secrets.
- Redash-native dashboard and data-source content belongs to tenant data products, not this reusable module.
