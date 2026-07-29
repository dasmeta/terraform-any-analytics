# Implementation Plan: Released Helm-only Analytics Workloads

**Branch**: `012-helm-chart-standardization`

The prior direct Kubernetes resources violate the Helm-only convention and are superseded. The published `metabase`, `postgrest`, and `redash` charts are all v0.1.0; dbt uses `base-cronjob` v0.1.39. Terraform consumes those immutable released artifacts through `helm_release` only.

Terraform will use only `helm_release` resources. No chart templates, manifests, or custom charts are added locally. Existing modules retain narrow consumer contracts and pass only opinionated, component-specific values to the shared charts.

| Module | Chart | Runtime |
| --- | --- | --- |
| dbt | `base-cronjob` 0.1.39 | one scheduled native dbt command |
| PostgREST | `postgrest` 0.1.0 | one private API service with an environment Secret |
| Metabase | `metabase` 0.1.0 | one private BI service with an environment Secret |
| Redash | `redash` 0.1.0 | native five-component topology; server init-container runs `create_db` |

Airbyte already uses a maintained upstream Helm chart, so no workload correction is required there. The direct-resource branches remain audit history only and must not be opened as PRs.

## Current state and standards assessment

- The dbt and Redash modules still declare Kubernetes provider resources; Metabase and PostgREST contain partial base-chart conversions. All four need a complete Helm-only implementation.
- Existing modules use flat variables unless a value is intrinsically grouped. The dbt image is grouped because repository, tag, and pull policy form one atomic container-image contract; every field will retain inline comments. The other module inputs remain flat because their names and Secret references are unambiguous.
- `base-cronjob` v0.1.39 does not render its broad `envFrom` list. dbt therefore exposes an explicit `configuration_secret_keys` list and uses the chart's supported Secret-key mechanism; this is a narrower, least-privilege contract.
- No suitable provider-maintained Terraform module exists for these chart-specific workloads. The Helm provider is the supported wrapper baseline; direct-resource scaffolding is not used.
- The new capability is supported by the repository's Helm provider constraint (`~> 3.0`); this uses the documented `helm_release` resource and published HTTP chart repository path.
- Existing direct-resource interfaces are not published on `main`; replacing their image/file-secret interfaces with released chart contracts therefore has no published-consumer breaking change. The updated README and examples document the new Secret keys.

## Proposed files and validation

- Replace `main.tf`, `outputs.tf`, `versions.tf`, basic examples, and basic test providers for dbt, Metabase, PostgREST, and Redash.
- Update their READMEs to describe released chart versions, Secret contracts, and release-derived service names.
- Preserve Airbyte as-is and validate it with the same Helm-provider convention.
- Add component YAML IaC DSL examples using the established `source`, `version`, and `variables` structure. The customer IaC repository supplies the Helm provider context and chooses the released Terraform module version.
- Run `terraform fmt -check -recursive`, `terraform init -backend=false` and `terraform validate` for each basic test, and `helm template` for the four chart value payloads where practical.
- Run the same provider-independent validation in GitHub Actions with Terraform v1.15.8. The repository's legacy shared Terraform test action configures AWS credentials unconditionally and therefore cannot validate these Helm-only fixtures; it is replaced here with the equivalent checkout, setup, init, and validate steps. The validation matrix must not fail fast so all component results remain visible.

## Gates

- Speckit evidence: `spec.md`, `plan.md`, and `tasks.md` are present under this feature package.
- No interface-widening or published breaking-change approval is required: unpublished direct-resource branches are superseded by the explicitly requested Helm-only architecture.
- No CloudBrowser update is proposed; this is reusable catalog work with no resolved customer context.
- PR feedback requires three bounded corrections: make Terraform validation gating, pin all Redash runtime and initializer images by digest, and validate Redash release names before deriving service outputs.
- The first CI run at commit `25e728b` failed before Terraform executed because the legacy shared action's AWS credential setup received an invalid token. This is infrastructure-independent module validation, not a module failure; the workflow is corrected without adding an AWS dependency.
