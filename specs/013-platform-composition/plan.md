# Implementation Plan: Analytics platform composition module

**Branch**: `013-platform-composition` | **Date**: 2026-07-30 | **Spec**:
[spec.md](spec.md)

## Summary

Make this repository's Terraform root an opinionated product-level module that
composes the existing Airbyte, dbt, PostgREST, and one selected visualization
runtime. It does not own shared infrastructure: callers create namespace,
Authentik, database, storage, Redis, and Secret prerequisites through their
respective modules and pass only the values required here.

## Current State and Deliberate Architecture Decision

`terraform-any-analytics` v1.0.0 contains five independent Helm modules and
per-component YAML examples. `terraform-any-shared` now supplies separate
namespace and Authentik modules. The original 001 plan explicitly avoided a
single all-in-one module; the approved next increment changes that boundary to
provide a strictly managed, one-entry-point platform deployment.

HashiCorp's [module-composition guidance](https://developer.hashicorp.com/terraform/language/modules/develop/composition)
strongly prefers a flat module tree and dependency inversion. This module is a
bounded product exception: it contains one level of local runtime children,
does not embed shared prerequisites, and receives its namespace/dependency
contracts from the caller. A customer IaC root still owns the actual provider,
state, shared module calls, and the decision to use this product composition.

## Technical Context

- **Terraform / provider constraints**: Terraform `~> 1.3`, HashiCorp Helm
  `~> 3.0`, matching repository convention.
- **Target module**: repository root with `main.tf`, `variables.tf`,
  `outputs.tf`, `versions.tf`, root `README.md`, `examples/basic`, and `tests`.
- **Composition baseline**: local `./modules/airbyte`, `./modules/dbt`,
  `./modules/postgrest`, `./modules/metabase`, and `./modules/redash` modules;
  configured Helm provider is inherited from the caller.
- **YAML**: `examples/yaml/platform.yaml` uses the established IaC DSL; actual
  customer configuration remains in its IaC config repository.
- **Automation**: add the module to the existing Terraform validation matrix;
  run format, init/validate, Terraform tests, documentation generation, and
  available static checks.

## Module Interface

`namespace` stays a flat required input because it is the one shared external
dependency. Each optional component is a grouped object because its fields are
an unambiguous component-specific contract. Every grouped field will carry an
inline comment in `variables.tf`; non-critical fields use optional attributes.

| Input | Required | Purpose |
| --- | ---: | --- |
| `namespace` | yes | Existing namespace, normally passed from the shared namespace module output. |
| `airbyte` | no | Airbyte external PostgreSQL and S3 Secret/reference contract. |
| `dbt` | no | Data-product-owned dbt image, command, schedule, and Secret reference. |
| `postgrest` | no | Existing `PGRST_*` Secret and runtime sizing contract. |
| `visualization` | no | Provider selector (`metabase` default) and exactly one matching provider configuration. |

No generic Helm escape hatch is added. Component-specific modules remain the
only place to add a reviewed service capability. There are currently no
alternative ingestion, transformation, or API providers, so provider selectors
are deliberately limited to visualization rather than inventing an abstraction
with one implementation.

## Modern Capabilities and Upstream Check

| Net-new ability | Classification | Evidence / decision |
| --- | --- | --- |
| Terraform module composition | supported | Terraform 1.15 official guidance documents module composition and dependency inversion; local children inherit the configured Helm provider. |
| Visualization provider choice | supported | It selects existing, non-deprecated local modules; no provider API or Helm feature is introduced. |
| Shared prerequisite integration | supported | Dependency inversion: consume the caller-provided namespace string; do not create, discover, or embed a shared module. |

Approved AWS, Azure, and Google provider-maintained module collections were
considered and have no relevant product-level wrapper for a vendor-neutral
Kubernetes analytics runtime suite. The direct-resource scratch template is
not applicable because this module contains only child modules and no resources.

## File Changes

1. Add the root platform module, typed selection validation, and endpoint/status
   outputs.
2. Add neutral Terraform example and validation fixture, including an
   executable invalid-provider test.
3. Generate root-module documentation in the repository README while retaining
   component-level use cases.
4. Add a complete generic `platform.yaml` example and register the module in
   validation CI.
5. Update the existing 001 roadmap to mark completed components and replace
   its no-composition statement with this approved bounded exception.

## Risks and Stop Conditions

- Do not add Authentik, namespace, database, ingress, DNS, Secret, or tenant
  configuration to this module; those would violate the dependency boundary.
- Do not make visualization configuration optional once its provider is
  selected; reject invalid combinations before Helm planning.
- If a second provider for ingestion, transformation, or API is introduced,
  define that provider contract in a separate approved feature rather than
  expanding this one speculatively.
- This remains a local composition module. Publishing cross-repository source
  pins inside it would turn runtime release selection into hidden state and is
  out of scope.
