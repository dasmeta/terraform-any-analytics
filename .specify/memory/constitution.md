# Terraform Any Analytics Constitution

## Core Principles

### I. Narrow, composable modules

Each runtime module owns its Helm release and its runtime-specific validation.
The repository root may compose released local runtime modules only; it does
not become a general Helm-values pass-through or own shared infrastructure.
The root composition role is an approved product exception for this repository.

### II. Explicit ownership boundaries

The caller owns cluster access, namespace creation, identity, database
instances, database/user/grant provisioning, object storage, Redis, Secrets,
ingress, DNS, TLS, and tenant data products. Modules consume references to
those prerequisites and must never accept secret values.

### III. Helm-native workload delivery

Analytics runtimes are deployed through reviewed Helm charts and Helm provider
resources. Direct Kubernetes resources require an explicit, documented
exception when no suitable chart-based path exists.

### IV. Consumer contract evidence

Every material interface change keeps typed variables, outputs, README,
Terraform examples, YAML examples, tests, and CI coverage aligned. Grouped
object fields are optional where safe and carry inline descriptions.

### V. Spec Kit before material changes

Module-impacting changes require a matching `spec.md`, `plan.md`, and
`tasks.md` under `specs/<NNN>-<slug>/` before implementation. The downstream
repository's Spec Kit package is the evidence for the module-change gate.

## Repository Constraints

- Use Terraform's pessimistic version constraints unless a stronger
  repository-local requirement is documented.
- Keep customer names, hostnames, credentials, and secret values out of
  Terraform artifacts, examples, tests, and documentation.
- Preserve the existing `versions.tf`, examples, tests, README, and workflow
  conventions unless an approved change requires otherwise.
- Shared cross-repository governance remains owned by the DasMeta constitution
  repository and must be consulted for conflicts; this document records only
  repository-local delivery rules.

## Delivery and Review

- Record upstream-provider assessment, ownership boundaries, compatibility,
  interface impact, and validation in the active feature plan.
- Use official provider/platform documentation for capability and deprecation
  decisions. Do not add direct resources merely to avoid a Helm chart.
- Run formatting, executable Terraform tests/examples, generated docs, and
  repository checks appropriate to the changed interface before review.
- Review is required for releases and changes that affect module contracts.

## Governance

This constitution supplements, and never replaces, the DasMeta shared
constitution. Amendments require a reviewed pull request and an update to the
affected Spec Kit evidence. A conflict with shared governance must be surfaced
for approval rather than resolved silently.

**Version**: 1.0.0 | **Ratified**: 2026-07-30 | **Last Amended**: 2026-07-30
