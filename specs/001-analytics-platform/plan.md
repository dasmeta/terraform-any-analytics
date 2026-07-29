# Implementation Plan: Reusable Data Analytics Platform

**Branch**: `001-analytics-platform` | **Date**: 2026-07-29 | **Spec**: [spec.md](spec.md)  
**Input**: DMVP-10317 requirements and the confirmed platform architecture.

## Summary

Deliver a reusable, component-scoped analytics platform for existing customer
Kubernetes environments. The delivery separates shared capabilities,
analytics-specific capabilities, customer YAML Setups, and tenant data-product
configuration. It deliberately avoids a monolithic Terraform state and does
not provision cluster, network, physical database, database/user/grant, or
secret-management foundations.

## Technical Context

**Terraform Version**: `~> 1.3`, aligned with maintained DasMeta modules.  
**Providers / Upstream Baselines**: HashiCorp Helm and Kubernetes providers;
official service charts where maintained; direct Kubernetes resources only for
the smallest unsupported service-native runtime.  
**Target Module Paths**: `modules/airbyte`, `modules/dbt`,
`modules/postgrest`, `modules/metabase`, and `modules/redash`.  
**Examples / Tests in Scope**: One basic example and one validation fixture per
module, plus a repository-level release/quality baseline.  
**Automation Gates**: Terraform format/init/validate, module test fixtures,
README/example consistency, pre-commit, tflint, checkov, and CI.  
**Target Platform**: Existing customer Kubernetes cluster, standard database
and secret-management capabilities, and DasMeta YAML DSL with Terraform Cloud
as the supported v1 driver.  
**Constraints**: Separate module and Setup state per capability; existing
namespace/Auth­entik are shared capabilities; no secret values or
customer-specific names/hostnames in Terraform artifacts.  
**Scale/Scope**: Five analytics modules and the cross-repository delivery
handoffs needed for one greenfield platform installation.

## Architecture and Ownership

| Concern | Owner / repository | Delivery unit |
| --- | --- | --- |
| Shared namespace | `terraform-any-shared` | `modules/namespace` release |
| Shared identity | `terraform-any-shared` | `modules/authentik` release |
| Ingestion | `terraform-any-analytics` | `modules/airbyte` release |
| Transformation runtime | `terraform-any-analytics` | `modules/dbt` release |
| Governed API | `terraform-any-analytics` | `modules/postgrest` release |
| Default visualisation | `terraform-any-analytics` | `modules/metabase` release |
| Alternative visualisation | `terraform-any-analytics` | `modules/redash` release |
| Customer deployment intent | customer IaC repo | YAML Setups under `2-products/data-analytics/<environment>/` |
| Sources, transformations, dashboards, AI use cases | tenant data-product repo | orchestrator stages `00`–`04` |

## Component Interface Rules

Every analytics module:

1. accepts an existing namespace and never creates one;
2. consumes pre-created database/secret interfaces and never creates physical
   database resources, databases, users, or grants;
3. exposes a narrow, typed operational interface rather than a generic
   `values` or arbitrary chart-pass-through object;
4. uses a pinned, documented upstream chart/image baseline and atomic release
   behavior where a Helm release is used;
5. delegates service initialization/migrations to the service's documented
   native behavior;
6. returns only useful, non-secret deployment identities; and
7. includes a neutral basic example and validation fixture.

### dbt-specific boundary

dbt is a transformation runner, not a long-lived UI service. The `dbt` module
will provide a scheduled or on-demand runner capability that executes a
pre-built, data-product-owned dbt project image and native dbt command. It will
not contain customer models, generate SQL, or publish a default transformation.
The exact workload form and supported image/secret reference must be selected
from official dbt/Kubernetes evidence in the module-specific Speckit package
before code is written.

## Delivery Phases

### Phase 0 — Shared prerequisites

1. Release `terraform-any-shared//modules/namespace`.
2. Create and release `terraform-any-shared//modules/authentik`, with external
   database and secret references, ingress integration, and no analytics
   configuration.
3. Record released source/version pins. No customer Setup YAML may reference an
   unreleased module path.

### Phase 1 — Analytics repository foundation

1. Establish this repository's Speckit and quality baseline.
2. Add module layout conventions, test fixture conventions, provider version
   policy, release automation, and a module inventory README.
3. Research and record official chart/image baselines and licenses for each
   service before implementing that module.

### Phase 2 — Core data path

1. Implement Airbyte as a dedicated ingestion module.
2. Implement the dbt runner as a data-product-executed transformation
   capability.
3. Implement PostgREST as the governed API runtime over a pre-created curated
   API schema.
4. Validate these modules independently and publish compatible releases.

### Phase 3 — Visualisation choices

1. Implement Metabase as the default visualisation module.
2. Implement Redash as an independent supported alternative, not a replacement
   or dependency of Metabase.
3. Make dashboard content explicitly tenant-data-product owned; runtime modules
   do not create customer dashboards by default.

### Phase 4 — YAML-only customer composition

1. Add standard Setup files under
   `dasmeta-infrastructure/2-products/data-analytics/<environment>/`:
   `namespace.yaml`, `authentik.yaml`, `airbyte.yaml`, `dbt.yaml`,
   `postgrest.yaml`, and one selected visualisation Setup.
2. Use the existing DSL fields only: `source`, `version`, `variables`,
   `providers`, and `linked_workspaces`.
3. Link to existing cluster, database, secret, DNS, and ingress Setups. Do not
   create Terraform files in the customer IaC repository.
4. Run the standard YAML validation → generation → Terraform Cloud VCS-plan
   workflow.

### Phase 5 — Orchestrator and tenant handoff

1. Keep the generic orchestrator limited to capability catalog, strict change
   boundary, and data-product stage contracts.
2. Populate the private tenant fork with its own `00-requirements` through
   `04-ai-use-cases` repositories or equivalent stage configuration.
3. Treat the existing Jira PoC as an optional example data product, not a
   platform default.

### Phase 6 — Greenfield validation and release evidence

1. Deploy to a dedicated namespace without importing the proof-of-concept
   namespace.
2. Validate namespace, identity proxy, component health, secret references,
   database connectivity, ingress, PostgREST API reachability, and Galust SaaS
   integration boundary.
3. Capture Terraform Cloud plan evidence and module/YAML validation evidence.
4. Open repository PRs and link delivery evidence back to DMVP-10317. Move the
   Jira item to review only after actual delivery is complete.

## Dependency Graph

```text
namespace release ─┬─> Authentik release ─┐
                   └─> analytics modules ─┼─> released module pins
database/secret/cluster interfaces ────────┘          │
                                                       v
                                      customer YAML Setups and TFC plan
                                                       │
                                                       v
                                  tenant data products and Galust use cases
```

## Module-Specific Speckit Packages

Each module-impacting repository change receives its own complete package
(`spec.md`, `plan.md`, `tasks.md`) before source changes:

- `terraform-any-shared/specs/010-shared-namespace`: active; first release
  dependency.
- `terraform-any-shared/specs/<next>-authentik`: required next.
- `terraform-any-analytics/specs/<next>-airbyte`: required before Airbyte code.
- `terraform-any-analytics/specs/<next>-dbt-runner`: required before dbt code.
- `terraform-any-analytics/specs/<next>-postgrest`: required before API code.
- `terraform-any-analytics/specs/<next>-metabase`: required before default BI
  code.
- `terraform-any-analytics/specs/<next>-redash`: required before alternative
  BI code.

## Validation and Release Gates

| Gate | Required evidence |
| --- | --- |
| Module plan | Official source/versions, narrow interface decision, examples/tests, no unresolved security or licensing concern. |
| Module implementation | `terraform fmt`, fixture `init -backend=false`, `validate`, static checks, and CI coverage. |
| Module release | Published semantic version; generated README and examples match interface. |
| YAML composition | `meta validate-yaml`, generated driver workspace update, and Terraform Cloud plan visible from VCS. |
| Greenfield platform | Component health and authorized endpoint checks; no customer data product assumed. |

## Risks and Stop Conditions

- Stop a module before code if no official or DasMeta-approved upstream runtime
  baseline, licence posture, or secure secret/database interface can be
  established.
- Do not expose unbounded chart values to work around a missing interface; add a
  bounded, documented input only when the common case requires it.
- Do not create customer YAML until all referenced module versions are released.
- Do not import the PoC namespace as part of v1 greenfield deployment.
- Do not treat a local Terraform validation as evidence that Terraform Cloud has
  planned or applied the customer composition.
