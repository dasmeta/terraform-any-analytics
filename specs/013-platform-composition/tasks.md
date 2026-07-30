# Tasks: Analytics platform composition module

**Input**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, and
`quickstart.md` in `specs/013-platform-composition/`.

**Historical note**: The implementation predated Spec Kit bootstrap. Completed
tasks below are reconciled against committed code and validation evidence; they
must not be read as a claim that their tests were created before implementation.

## Phase 1: Setup

**Purpose**: Establish tracked Spec Kit evidence for this root-module feature.

- [x] T001 Bootstrap Codex-integrated Spec Kit in `.specify/` and record
  repository-local workflow guidance in `.specify/memory/constitution.md`.
- [x] T002 Create the active feature package in
  `specs/013-platform-composition/spec.md` and set
  `.specify/feature.json` to the active package.

## Phase 2: Foundational composition contract

**Purpose**: Define the bounded root interface before runtime selection.

- [x] T003 Define the root Terraform/provider constraints in `versions.tf`.
- [x] T004 Define required namespace, nullable runtime objects, and the
  exclusive visualization selector in `variables.tf`.
- [x] T005 Compose local child modules and expose selected-only outputs in
  `main.tf` and `outputs.tf`.

**Checkpoint**: The root can compose selected child modules without owning
shared infrastructure.

## Phase 3: User Story 1 — Deploy a selected runtime suite (Priority: P1)

**Goal**: Enable a caller to select Airbyte, dbt, PostgREST, and a visualization
runtime using a single root interface.

**Independent Test**: `examples/basic` and `tests/basic` initialize and
validate without a cluster or backend.

- [x] T006 [US1] Add optional Airbyte, dbt, and PostgREST local-module
  composition in `main.tf`.
- [x] T007 [P] [US1] Add a neutral full-suite consumer fixture in
  `examples/basic/main.tf`.
- [x] T008 [P] [US1] Add the basic validation fixture in `tests/basic/main.tf`
  and `tests/basic/providers.tf`.

**Checkpoint**: A consumer can deploy the selected non-visualization runtimes
without a cross-repository namespace or identity dependency.

## Phase 4: User Story 2 — Choose one visualization runtime (Priority: P1)

**Goal**: Select Metabase by default or Redash explicitly, without deploying
both.

**Independent Test**: Terraform validation tests reject invalid/ambiguous
input, allow no visualization, and select Redash alone.

- [x] T009 [US2] Implement Metabase and Redash selection locals and module
  wiring in `main.tf`.
- [x] T010 [US2] Add provider/shape validation in `variables.tf`.
- [x] T011 [US2] Add post-implementation regression coverage for invalid,
  ambiguous, omitted, and Redash-only cases in
  `tests/invalid_inputs.tftest.hcl`.

**Checkpoint**: Exactly one visualization provider is selected or neither is
deployed.

## Phase 5: User Story 3 — Consume through the IaC DSL (Priority: P2)

**Goal**: Give a customer IaC repository a neutral, releasable YAML entry
point without Terraform implementation files.

**Independent Test**: The YAML parses and uses only `source`, `version`, and
`variables` with no customer identity or secret values.

- [x] T012 [US3] Add the canonical platform YAML example in
  `examples/yaml/platform.yaml`.
- [x] T013 [US3] Document copy-and-pin consumption guidance in
  `examples/yaml/README.md` and `README.md`.

**Checkpoint**: An operator can copy the generic YAML into a company IaC
configuration repository and replace only release and prerequisite references.

## Phase 6: Polish and repository integration

**Purpose**: Keep the contract verifiable and reviewable.

- [x] T014 [P] Register root-fixture validation in
  `.github/workflows/terraform-test.yaml`.
- [x] T015 [P] Generate and reconcile root module documentation in `README.md`.
- [x] T016 Record module sourcing, ownership, compatibility, and design
  decisions in `specs/013-platform-composition/research.md`,
  `data-model.md`, and `quickstart.md`.
- [x] T017 Run `terraform fmt`, root/basic validation, `terraform test`,
  `terraform-docs`, YAML parsing, `git diff --check`, and available security
  checks; record results in `quickstart.md`.
- [x] T018 Run Spec Kit feature, plan, task, and prerequisite scripts for
  `specs/013-platform-composition/`.

## Phase 7: Workflow remediation

**Purpose**: Correct the evidence and verification gaps found by the
post-bootstrap module-developer audit without changing the public contract.

- [x] T019 Record CloudBrowser read-only catalog evidence and the deferred
  maintenance proposal in `specs/013-platform-composition/{plan,research}.md`.
- [x] T020 Restrict the local Spec Kit constitution to repository-local rules
  and point to shared governance in `.specify/memory/constitution.md`.
- [x] T021 Complete the required source, capability, interface, gate, gap, and
  proposed-file assessments in `specs/013-platform-composition/plan.md`.
- [x] T022 Add Terraform release-package exclusions in `.terraformignore`.
- [x] T023 Correct composition-root ownership wording in `README.md`.
- [x] T024 Add default-provider, matching-configuration, selected-runtime, and
  selected-only endpoint regression assertions in `tests/invalid_inputs.tftest.hcl`.
- [x] T025 Run the Spec Kit cross-artifact reconciliation and record its review
  findings in `specs/013-platform-composition/quickstart.md`.
- [x] T026 Run formatting, Terraform validation/tests, Terraform docs, YAML
  parsing, packaging checks, and diff checks; update
  `specs/013-platform-composition/quickstart.md`.

## Dependencies and execution order

- Setup establishes the workflow evidence.
- Foundational composition work defines the shared root interface.
- US1 and US2 depend on the foundational interface but are independently
  testable thereafter.
- US3 depends on the accepted public root contract, not on a deployed cluster.
- Polish verifies all completed stories and prepares review evidence.

## Implementation strategy

The MVP is US1 plus US2: a caller can compose the selected runtime suite and
get a safe visualization choice. US3 then makes that same contract consumable
by the existing IaC DSL. No step adds shared infrastructure or customer data
product configuration.
