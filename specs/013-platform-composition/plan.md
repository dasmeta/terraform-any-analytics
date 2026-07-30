# Implementation Plan: Analytics platform composition module

**Branch**: `013-platform-composition` | **Date**: 2026-07-30 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/013-platform-composition/spec.md`

## Summary

Make the repository root a small, reusable Terraform composition module for
the released analytics runtime modules. A caller supplies an existing
namespace and non-secret references to prerequisites; the module optionally
installs Airbyte, dbt, PostgREST, and exactly one visualization provider
(Metabase by default, Redash as an alternative). The same contract is shown in
a neutral Terraform example and in the existing IaC YAML DSL.

This package was bootstrapped after the root implementation existed. Its tasks
therefore reconcile and verify the delivered interface; they do not claim the
implementation was originally developed test-first.

## Technical Context

**Language/Version**: HCL; Terraform `~> 1.3`, verified with 1.15.8.

**Primary Dependencies**: `hashicorp/helm ~> 3.0`; local runtime modules in
`modules/airbyte`, `modules/dbt`, `modules/postgrest`, `modules/metabase`, and
`modules/redash`.

**Storage**: N/A. The module creates no database, object store, or stateful
data resource.

**Testing**: `terraform validate`, `terraform test`, `terraform-docs`, YAML
parse, `git diff --check`, and repository security checks where available.

**Target Platform**: Terraform callers managing a Kubernetes cluster with the
Helm provider; no backend or cluster is required for validation.

**Project Type**: Reusable Terraform module repository.

**Performance Goals**: Plan-time composition only; no runtime performance
claim. Each selected runtime keeps its own chart/resource configuration.

**Constraints**: Helm-native workload installation; no direct Kubernetes
resources; no secret values or generic chart escape hatch; customer-neutral
examples; existing shared prerequisites remain external.

**Scale/Scope**: One optional configuration object per supported runtime plus
one selected visualization provider. Tenant data products are intentionally
out of scope.

## Research and Design Decisions

See [research.md](research.md) for the decision record. The material choices
are:

- Compose local, reviewed runtime modules rather than recreate their Helm
  releases or expose raw chart values.
- Use one nullable grouped object for each optional component, and a provider
  selector with mutually exclusive visualization configuration.
- Treat the repository root as the approved, bounded product composition
  module. Runtime modules retain their existing `modules/<runtime>` layout.
- Keep namespace, Authentik, database/user/grant, storage, Redis, Secret,
  ingress, DNS, TLS, and data-product ownership external.
- Use the established `source` / `version` / `variables` YAML DSL rather than
  inventing an analytics-specific provisioning contract.

## Module-Developer Assessment

**Current state and scope**: The repository already contains component-scoped
Helm wrappers. This feature adds their root composition interface, root
documentation, examples/tests, a YAML example, root validation coverage, and
the release-package metadata required for Terraform distribution.

**Gaps against internal standards (before remediation)**: the root had no
`.terraformignore`; behavioral tests did not prove default Metabase selection,
missing selected-provider configuration, selected-only endpoint output, or the
complete selected runtime suite; README wording implied the composition root
directly owns a Helm release; and the Spec Kit package omitted a formal
retrospective workflow exception and catalog evidence.

**Repository convention**: Required providers remain in `versions.tf`. The
five local runtime modules consistently use `tests/basic/main.tf` with a
fixture `providers.tf`, plus `examples/`; the root preserves that local
convention instead of forcing the generic numbered test-file preference.
No closely related DasMeta module repository checkout was available in this
workspace for further comparison. The root module is the user-approved
exception to the prior component-only layout, documented as a composition root
rather than a new convention for runtime modules.

**Target platform and upstream assessment**: The target is Kubernetes via the
HashiCorp Helm provider, not AWS, Azure, or Google Cloud. The approved provider
collections were considered and have no candidate for vendor-neutral composition
of these analytics runtime charts; candidate set: none. The local runtime
modules are the chosen wrapper baseline. Their added usability is reviewed,
typed component configuration and chart-specific validation; the root adds only
selection and cross-runtime output shaping. Direct-resource fallback and the
scratch-template source are not applicable.

**Wrapper preservation**: The root has a deliberately smaller interface than
the child charts: it forwards only reviewed component configuration and
prevents generic Helm values. Grouped component objects are unambiguous;
non-critical fields use Terraform `optional(...)` and every grouped field has
an inline explanation in `variables.tf`.

**Modern capabilities**: no provider boundary changes. The net-new abilities
are all classified `supported`:

| Ability | Minimum boundary | Classification | Primary evidence |
|---------|------------------|----------------|------------------|
| Local child-module selection with `count` | Terraform `~> 1.3` | supported | [Terraform module composition](https://developer.hashicorp.com/terraform/language/modules/develop/composition) and [module block reference](https://developer.hashicorp.com/terraform/language/block/module) |
| Typed optional grouped configuration | Terraform `~> 1.3` | supported | [Terraform type constraints](https://developer.hashicorp.com/terraform/language/expressions/type-constraints) |
| Helm-native runtime installation in selected children | Helm provider `~> 3.0` | supported | [Helm provider documentation](https://registry.terraform.io/providers/hashicorp/helm/latest/docs) and [`helm_release` resource](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) |

The root creates no Helm release directly; selected child modules retain that
responsibility. No deprecated path is introduced and no replacement or
exception is required.

**Governance source**: shared governance source is
`https://github.com/dasmeta/meta-level-constitution`, observed at
`349db1f2f52185f41ef6ec4fe366752ef9bf5743`. The local Spec Kit constitution
contains repository-only constraints and must not duplicate shared policy.

**CloudBrowser**: Conditional reusable-catalog work. Read-only checks covered
Metabase module 171, Redash module 129, their matching component records,
module-version and module-solution relations, and associated documentation
lookups. The existing Metabase and Redash component context is deployment-
specific and does not establish a reusable-platform client/project scope.
Neither has a confirmed module version, solution relation, or documentation
relation for this root composition contract. No matching module records were
found for Airbyte, dbt, or PostgREST. Component-level ownership arrays were
empty; global module-level ownership was not asserted because the attempted
filter is unsupported by the API. Proposed, but not authorized: after a
published platform release, propose a generic root catalog record, its version
and applicable relations, then obtain explicit confirmation before writing.
No CloudBrowser mutation is part of this pull request.

**Module-change gate**: this retrospective bootstrap exception applies only to
commits `e56811c` through `f5d15c8` in PR #8 and expires when that PR is merged
or closed. The package now contains `spec.md`, `plan.md`, and `tasks.md`, and
the prerequisite check succeeds. Review must accept the exception; future
module-impacting changes MUST start with the normal specify → clarify → plan →
tasks sequence and cannot reuse it.

**Interface/breaking change**: There is no prior root module contract to
preserve. Existing component submodule interfaces remain unchanged. The root
interface is intentionally narrow and does not widen any child module.

**Proposed remediation files**: `.terraformignore`, `README.md`,
`tests/invalid_inputs.tftest.hcl`, `.specify/memory/constitution.md`, and this
feature package. No child runtime module source, variable, output, chart
version, provider constraint, or customer IaC YAML changes are proposed.

**Conflicts and approvals**: no breaking or interface-widening change is
proposed. The user approved the root composition exception and this remediation
scope. The only review decision remaining is acceptance of the bounded,
retrospective Spec Kit bootstrap exception above.

## Constitution Check

**Pre-design gate: pass.**

- Narrow composition: pass — root composes local modules and does not forward
  arbitrary Helm values.
- Ownership: pass — all shared prerequisites are caller-owned references.
- Helm-native workloads: pass — child runtime modules own Helm releases.
- Consumer evidence: pass — source, examples, YAML, tests, README, and CI are
  part of the feature scope.
- Spec Kit evidence: pass after bootstrap — active package is
  `specs/013-platform-composition/`.

**Post-design re-check: pass.** The data model and quickstart preserve these
same boundaries; no direct Kubernetes resource, secret value, or shared
infrastructure input was introduced.

## Project Structure

### Documentation (this feature)

```text
specs/013-platform-composition/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── checklists/requirements.md
└── tasks.md
```

No external HTTP contract exists: this feature's public contract is the
Terraform variables/outputs and the YAML DSL representation documented in
`data-model.md`.

### Source Code (repository root)

```text
main.tf                         # optional local-module composition
variables.tf                    # typed, validated consumer interface
outputs.tf                      # selected endpoints and release statuses
versions.tf                     # Terraform and Helm provider constraints
README.md                       # generated and authored module documentation
modules/<runtime>/              # existing component Helm wrapper modules
examples/basic/                 # full neutral Terraform consumer example
examples/yaml/platform.yaml     # generic IaC DSL representation
tests/                          # Terraform test fixture and validation cases
.github/workflows/terraform-test.yaml
```

**Structure Decision**: Use the repository root as the sole product
composition module, while retaining `modules/<runtime>` for independently
reusable runtime wrappers. Shared infrastructure deliberately stays outside
this repository.

## Complexity Tracking

| Exception | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Root composition module | Operators need one released analytics-platform entry point and one canonical YAML source. | Requiring every consumer to orchestrate five child modules duplicates selection and validation rules. |
