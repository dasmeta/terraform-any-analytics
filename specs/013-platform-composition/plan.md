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
documentation, examples/tests, a YAML example, and root validation coverage.

**Repository convention**: Required providers remain in `versions.tf`; tests
and examples remain under `tests/` and `examples/`. The root module is the
user-approved exception to the prior component-only layout. It is documented
as a composition root, not a new convention for runtime modules.

**Upstream assessment**: The approved AWS, Azure, and Google provider module
collections do not provide a vendor-neutral composition module for these
Kubernetes analytics Helm runtimes. The local runtime modules are the intended
opinionated wrappers; a direct-resource fallback and the scratch-template
source are not applicable.

**Wrapper preservation**: The root has a deliberately smaller interface than
the child charts: it forwards only reviewed component configuration and
prevents generic Helm values. Grouped component objects are unambiguous;
non-critical fields use Terraform `optional(...)` and every grouped field has
an inline explanation in `variables.tf`.

**Modern capabilities**: `supported`. This feature uses Terraform module
composition and the established Helm provider path; it introduces no
deprecated provider capability and does not change the child modules'
provider support boundary.

**Governance source**: Shared rules remain sourced from the DasMeta
constitution repository. The local Spec Kit constitution records only this
repository's composition and delivery constraints.

**CloudBrowser**: Conditional reusable-catalog work. No customer or catalog
record is in scope and no authorized catalog mutation is proposed.

**Module-change gate**: Compatible after this package contains `spec.md`,
`plan.md`, and `tasks.md` and the generated prerequisite check succeeds.

**Interface/breaking change**: There is no prior root module contract to
preserve. Existing component submodule interfaces remain unchanged. The root
interface is intentionally narrow and does not widen any child module.

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
