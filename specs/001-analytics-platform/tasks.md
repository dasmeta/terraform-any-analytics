# Tasks: Reusable Data Analytics Platform

**Input**: `specs/001-analytics-platform/` design artifacts.  
**Prerequisites**: Shared namespace and Authentik releases; one complete
module-level Speckit package before each component module implementation.

## Phase 1: Repository Foundation

- [x] T001 Define and commit repository module conventions, quality gates, and Terraform ignore rules in `README.md`, `AGENTS.md`, `.gitignore`, and `.github/workflows/`.
- [x] T002 Record the platform delivery plan and component ownership in `specs/001-analytics-platform/plan.md`.
- [x] T003 Add a maintained-module inventory and release policy in `README.md`.

## Phase 2: Shared Capability Prerequisites

- [ ] T004 Confirm the released `terraform-any-shared//modules/namespace` version in the customer composition plan.
- [ ] T005 Create, validate, release, and document `terraform-any-shared//modules/authentik` through its own Speckit package.
- [ ] T006 Record the shared namespace/Auth­entik source and version pins in the customer YAML examples.

## Phase 3: User Story 1 - Deploy data intake (Priority: P1)

**Goal**: Deliver a narrowly scoped Airbyte module that consumes existing
namespace, database, and secret interfaces.

**Independent Test**: The Airbyte module's basic fixture validates with neutral
inputs and does not create namespace or database infrastructure.

- [x] T007 [US1] Create a module-specific Speckit package for `modules/airbyte` under `specs/`.
- [x] T008 [US1] Research and pin the official Airbyte deployment baseline in the Airbyte package `research.md`.
- [x] T009 [US1] Implement typed Airbyte runtime inputs, native secret references, release wiring, outputs, example, test, and README in `modules/airbyte/`.
- [x] T010 [US1] Run module format, validation, static checks, CI, and publish a released Airbyte version.

## Phase 4: User Story 2 - Publish governed analytical access (Priority: P1)

**Goal**: Deliver independent dbt runner and PostgREST modules over pre-created
data interfaces.

**Independent Test**: Each module validates independently, with no database,
user/grant, namespace, or arbitrary SQL creation behavior.

- [x] T011 [US2] Create and complete the module-specific Speckit package for `modules/dbt`.
- [x] T012 [US2] Implement the typed dbt-runner capability, including data-product-owned image/command references, example, test, and README in `modules/dbt/`.
- [x] T013 [US2] Create and complete the module-specific Speckit package for `modules/postgrest`.
- [x] T014 [US2] Implement the typed PostgREST runtime, native configuration/secret references, example, test, and README in `modules/postgrest/`.
- [x] T015 [US2] Validate and publish compatible dbt and PostgREST releases.

## Phase 5: User Story 3 - Offer supported visualisation choices (Priority: P2)

**Goal**: Deliver independent Metabase and Redash runtime modules, with
Metabase documented as the default and dashboard content kept outside runtime
provisioning.

**Independent Test**: Each visualisation module validates independently and
does not create tenant dashboard content by default.

- [x] T016 [US3] Create and complete the module-specific Speckit package for `modules/metabase`.
- [x] T017 [US3] Implement Metabase runtime, external application database/secret references, example, test, and README in `modules/metabase/`.
- [x] T018 [US3] Create and complete the module-specific Speckit package for `modules/redash`.
- [x] T019 [US3] Implement Redash runtime, external application database/secret references, example, test, and README in `modules/redash/`.
- [x] T020 [US3] Validate and publish compatible Metabase and Redash releases.

## Phase 6: Customer YAML Composition

- [ ] T021 Add standard product Setup YAML files under `dasmeta-infrastructure/2-products/data-analytics/<environment>/` for released shared and analytics modules.
- [ ] T022 Add only standard `source`, `version`, `variables`, `providers`, and `linked_workspaces` fields; link existing cluster, database, secret, ingress, and DNS Setups.
- [ ] T023 Validate YAML, regenerate driver artifacts through the existing provisioner, push generated Terraform Cloud workspace output, and review remote plans.

## Phase 6a: Standard platform composition

- [x] T027 Create and validate the repository root as a bounded composition of
  selected local analytics modules, with no shared-infrastructure ownership.
- [x] T028 Add a canonical `platform.yaml` example while retaining independent
  component examples for separate-state consumers.

## Phase 7: Tenant and Greenfield Evidence

- [ ] T024 Align generic orchestrator capability references and the private tenant workspace without adding runtime provisioning to either repository.
- [ ] T025 Deploy the greenfield platform namespace and validate identity, component health, database connectivity, ingress, API reachability, and Galust boundary.
- [ ] T026 Record release, plan, validation, and PR evidence in DMVP-10317; transition to review only after the full delivery completes.

## Dependencies and Execution Order

Phase 2 blocks every analytics module. Within Phase 3–5, each module has its
own package and release; Airbyte, dbt, PostgREST, Metabase, and Redash do not
share Terraform state. Phase 6 begins only after referenced releases exist.
Phase 7 begins only after customer YAML plans successfully through the selected
driver.

## MVP Strategy

The first usable platform increment is: released namespace + Authentik +
Airbyte + dbt runner + PostgREST, followed by customer YAML plan evidence.
Metabase completes the default visualisation increment. Redash is additive and
does not block the default path.
