# Tasks: Analytics platform composition module

**Input**: `spec.md` and `plan.md` in this directory.

## Phase 1 — Composition interface

- [x] T001 Make the repository root the platform module with repository-standard Terraform and
  Helm provider constraints.
- [x] T002 Define the narrow namespace, optional component, and visualization
  selection interface with documented validation.
- [x] T003 Compose local Airbyte, dbt, PostgREST, Metabase, and Redash modules
  without creating or sourcing shared prerequisites.
- [x] T004 Expose selected runtime endpoint and release-status outputs only.

## Phase 2 — Consumer evidence

- [x] T005 Add a complete neutral Terraform basic example and validation
  fixture for a Metabase-selected full platform.
- [x] T006 Add executable Terraform tests for invalid, ambiguous, and omitted
  visualization choices and composition precedence.
- [x] T007 Generate root `README.md` module documentation with ownership boundaries,
  module usage, selection rules, and downstream integration notes.
- [x] T008 Add `examples/yaml/platform.yaml` and update the YAML examples guide
  to explain copy/release-pin usage.

## Phase 3 — Repository integration and verification

- [x] T009 Register the root platform module in the Terraform validation workflow.
- [x] T010 Update the root README and the 001 platform roadmap to identify the
  approved composition module and completed component releases.
- [x] T011 Run format, basic fixture init/validate, Terraform tests,
  terraform-docs, and available repository checks.
- [x] T012 Commit/push the feature branch and create a PR with validation
  evidence: https://github.com/dasmeta/terraform-any-analytics/pull/8
- [ ] T013 Bootstrap the repository's tracked Spec Kit project and execute the
  actual Speckit workflow for this feature, or record an approved governance
  exemption. This remains blocked pending repository-framework direction.

## Validation Evidence

- `asdf exec terraform fmt -check -recursive`: passed.
- `asdf exec terraform -chdir=examples/basic init -backend=false`
  and `validate`: passed with HashiCorp Helm provider `3.2.0`.
- `asdf exec terraform -chdir=tests/basic init -backend=false`
  and `validate`: passed with HashiCorp Helm provider `3.2.0`.
- `asdf exec terraform test`: passed four cases:
  invalid provider, ambiguous provider configuration, and Redash-only
  selection.
- `terraform-docs markdown table --output-file README.md --output-mode inject .`:
  updated generated root-module input/output documentation.
- `checkov -d . --quiet`: passed; Checkov emitted only a
  sandbox-DNS warning while attempting to refresh external guidance.
- Ruby YAML parsing of `examples/yaml/platform.yaml` and `git diff --check`:
  passed.
