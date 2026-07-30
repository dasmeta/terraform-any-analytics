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
- [x] T018 Bootstrap the Spec Kit feature package and run prerequisite checks
  for `specs/013-platform-composition/`.

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
  selected-only endpoint/status regression assertions in
  `tests/invalid_inputs.tftest.hcl`.
- [x] T025 Run the Spec Kit cross-artifact reconciliation and record its review
  findings in `specs/013-platform-composition/quickstart.md`.
- [x] T026 Run formatting, Terraform validation/tests, Terraform docs, YAML
  parsing, packaging checks, and diff checks; update
  `specs/013-platform-composition/quickstart.md`.

## Phase 8: Complete the Spec Kit chain

**Purpose**: Execute the required downstream workflow after the historical
implementation was reconciled, without changing the public module contract.

- [x] T027 Run the clarification scan against
  `specs/013-platform-composition/spec.md` and record that no critical
  ambiguity requires a spec edit.
- [x] T028 Update the technical plan, research evidence, and agent context in
  `specs/013-platform-composition/{plan,research}.md` and `AGENTS.md`.
- [x] T029 Regenerate the executable story-oriented plan in
  `specs/013-platform-composition/tasks.md`, including dependency and parallel
  execution guidance.
- [x] T030 Run the read-only cross-artifact analysis over
  `specs/013-platform-composition/{spec,plan,tasks}.md` and resolve any
  blocking findings before implementation.
- [x] T031 Execute the remaining implementation validation and mark completed
  work in `specs/013-platform-composition/{spec,tasks,quickstart}.md`.

## Dependencies and execution order

- Setup establishes the workflow evidence.
- Foundational composition work defines the shared root interface.
- US1 and US2 depend on the foundational interface but are independently
  testable thereafter.
- US3 depends on the accepted public root contract, not on a deployed cluster.
- Polish verifies all completed stories and prepares review evidence.
- The final workflow phase depends on the completed story tasks; analysis is
  read-only and implementation follows only when it has no blocking finding.

## Requirement coverage

| Requirement | Covered by | Evidence |
|-------------|------------|----------|
| FR-001, FR-002, FR-003 | T003–T008 | Root composition and basic fixture |
| FR-004 | T009–T011 | Visualization selection and validation cases |
| FR-005 | T005, T011 | Selected-only output shaping and regression test |
| FR-006 | T004, T016 | Typed inputs and documented ownership boundary |
| FR-007 | T012–T018, T026 | Examples, docs, CI matrix, and validation record |

## Parallel opportunities

- **US1**: After T006 establishes module wiring, T007
  (`examples/basic/main.tf`) and T008 (`tests/basic/*`) can proceed in
  parallel because they modify different fixtures.
- **US2**: T009 and T010 share root-module files and remain sequential; T011
  follows both and independently modifies `tests/invalid_inputs.tftest.hcl`.
- **US3**: T012 (`examples/yaml/platform.yaml`) and the README portion of T013
  can proceed in parallel after the root public contract is accepted; the YAML
  README is finalized after the example is present.

## Parallel examples

### User Story 1

```text
T007: Add the consumer fixture in examples/basic/main.tf
T008: Add the validation fixture in tests/basic/main.tf and tests/basic/providers.tf
```

### User Story 2

No safe parallel implementation task exists: validation and selection both
shape the root contract and T011 depends on them.

### User Story 3

```text
T012: Add examples/yaml/platform.yaml
T013: Draft the root README consumption guidance
```

## Implementation strategy

The MVP is US1 plus US2: a caller can compose the selected runtime suite and
get a safe visualization choice. US3 then makes that same contract consumable
by the existing IaC DSL. No step adds shared infrastructure or customer data
product configuration. The final workflow phase confirms the retrospective
evidence instead of treating bootstrap scripts as a replacement for the
Clarify → Plan → Tasks → Analyze → Implement chain.
