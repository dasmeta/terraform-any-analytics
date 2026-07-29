# Feature Specification: Reusable Analytics Platform Modules

**Feature Branch**: `001-analytics-platform`  
**Created**: 2026-07-29  
**Status**: Ready for planning  
**Input**: DMVP-10317 — reusable, customer-deployable data analytics platform.

## Module Context

- **Target Module Paths**: `modules/airbyte`, `modules/dbt`, `modules/postgrest`,
  `modules/metabase`, and `modules/redash`.
- **Related Files In Scope**: Each module's Terraform source, README, basic
  example, and executable validation test; repository-level module baseline only
  where it is necessary to support all five modules.
- **Upstream Baseline**: Official Helm charts for runtime services; direct
  Kubernetes resources only where the chart cannot own the required native
  object. The provider-managed chart is always preferred to handwritten
  manifests.
- **Requested Interface Change**: New, narrowly scoped consumer modules that
  deploy one analytics service into a pre-existing Kubernetes namespace and
  consume pre-created database and secret interfaces.
- **Breaking Change / Interface Widening**: None. This feature creates new
  module paths and deliberately does not expose complete upstream chart values.

## User Scenarios & Testing

### User Story 1 - Deploy data intake (Priority: P1)

An infrastructure operator can deploy an approved ingestion service into a
dedicated platform namespace using documented external database and secret
references, without creating database infrastructure in the analytics module.

**Why this priority**: Intake is the first reusable capability needed to turn
an approved source contract into platform data.

**Independent Test**: A clean example validates the intake module's required
inputs and rendered release configuration without credentials or a customer
hostname.

**Acceptance Scenarios**:

1. **Given** a reachable Kubernetes provider, a namespace, and secret/database
   references, **When** the operator uses the documented intake module example,
   **Then** validation accepts the configuration without requiring unmanaged
   infrastructure.
2. **Given** omitted optional tuning, **When** the module is planned, **Then**
   it uses its documented safe defaults rather than requiring chart internals.

---

### User Story 2 - Publish governed analytical access (Priority: P1)

An infrastructure operator can deploy transformation and API capabilities that
consume approved data interfaces and expose only their documented operational
configuration.

**Why this priority**: A platform is not complete when it only collects data;
it needs a repeatable transformation and governed access path.

**Independent Test**: Each transformation and API module has an independently
validating example that proves namespace, database/secret reference, and
service configuration boundaries.

**Acceptance Scenarios**:

1. **Given** a certified database interface and namespace, **When** the
   operator configures transformation and API modules, **Then** neither module
   attempts to create physical databases, users, or grants.
2. **Given** service-native initialization is required, **When** a module is
   deployed, **Then** the service's supported native mechanism remains the
   owner rather than a generic bootstrap script.

---

### User Story 3 - Offer supported visualisation choices (Priority: P2)

An infrastructure operator can deploy the default visualisation service or the
supported alternative as independently managed capabilities.

**Why this priority**: Operators need a supported presentation layer while
retaining a safe migration and upgrade boundary between alternatives.

**Independent Test**: Both visualisation modules validate independently and
their examples make clear that dashboard content is a tenant data-product
responsibility.

**Acceptance Scenarios**:

1. **Given** an approved namespace and data connection reference, **When** the
   operator chooses the default visualisation module, **Then** it can be
   validated without deploying the alternative.
2. **Given** a need for the supported alternative, **When** it is selected,
   **Then** it is deployed as a separate state and does not replace or mutate
   the default visualisation setup.

### Edge Cases

- A module receives a namespace that does not exist: it fails through the
  provider rather than creating a second namespace outside the shared namespace
  ownership boundary.
- A caller supplies inline database passwords or customer hostnames: examples
  and module interface must not require or document those values.
- A service chart changes an unsupported value: the wrapper pins and exposes
  only the tested, common operational settings.
- A caller needs resource quotas, network policies, databases/users/grants, or
  certificate/DNS infrastructure: those remain separate shared or environment
  Setup concerns.

## Requirements

### Functional Requirements

- **FR-001**: Each module MUST own one analytics runtime capability and one
  Helm release or comparably cohesive native resource set.
- **FR-002**: Each module MUST accept an existing namespace and MUST NOT create
  a namespace, physical database, database, user, grant, cluster, or network
  foundation.
- **FR-003**: Each module MUST support secret references or existing native
  secrets; it MUST NOT require secret values in examples or documentation.
- **FR-004**: The module collection MUST include Airbyte, dbt, PostgREST,
  Metabase, and Redash as separately deployable paths.
- **FR-005**: Metabase MUST be the documented default visualisation choice;
  Redash MUST remain a separately deployable supported alternative.
- **FR-006**: Modules MUST preserve each service's native initialization and
  migration behavior and MUST NOT add a generic bootstrap job that reproduces
  it.
- **FR-007**: Each module MUST document a narrow, stable interface, provide a
  basic example and test, and publish useful non-secret outputs.
- **FR-008**: The collection MUST be consumable from the existing DasMeta YAML
  DSL through released source and version pins; it must not introduce another
  YAML schema.

### Compatibility & Delivery Requirements

- **CDR-001**: The collection MUST use only DasMeta-controlled modules for
  customer IaC and must document all external chart/provider dependencies.
- **CDR-002**: The plan MUST record the official chart and provider baseline
  chosen for each module and the reasons unsupported upstream inputs are not
  forwarded.
- **CDR-003**: The implementation MUST include format, validation, module test,
  documentation, and example checks appropriate to each new module.
- **CDR-004**: The delivery plan MUST identify the predecessor shared namespace
  and Authentik modules, the customer YAML Setup phase, and the separate
  data-product/orchestrator phase.

### Key Entities

- **Analytics component module**: A separately versioned, single-service
  deployment capability with a narrow operational interface.
- **Namespace reference**: The shared, pre-existing deployment boundary that
  all analytics component modules consume.
- **Database interface reference**: A pre-provisioned connection or native
  secret reference supplied by standard database and secret-management
  capabilities.
- **Tenant data product**: Source, transformation, visualisation, and AI use
  case configuration owned outside this module repository.

## Assumptions

- The customer platform already provides a reachable Kubernetes cluster,
  ingress/DNS capability, secret-management capability, and database module
  contract.
- The shared namespace and Authentik modules are delivered and released before
  a customer applies analytics product Setups.
- Terraform Cloud is the initially supported driver, but customer configuration
  retains the standard driver-neutral YAML Setup form.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Five independently addressable component modules have matching
  documentation, example, and validation coverage.
- **SC-002**: A consumer can validate each documented example without a
  customer-specific hostname, database password, or manual service migration.
- **SC-003**: The customer IaC plan can represent every component as a separate
  standard Setup with a released DasMeta module version.
- **SC-004**: A change to one component module does not require changing or
  planning the other component modules.
- **SC-005**: The detailed delivery plan identifies every repository, release
  dependency, validation gate, and acceptance-evidence handoff needed for
  DMVP-10317.
