<!--
Sync Impact Report
- Version change: 1.0.0 -> 1.1.0
- Modified principles:
  - shared-policy restatement -> repository-local composition and packaging rules
- Added sections:
  - Shared Governance Source
- Removed sections:
  - duplicated shared delivery and review policy
- Templates requiring updates:
  - ✅ reviewed: .specify/templates/plan-template.md (existing Constitution Check remains applicable)
  - ✅ reviewed: .specify/templates/spec-template.md (no repository-local schema change)
  - ✅ reviewed: .specify/templates/tasks-template.md (no task format change)
  - ✅ updated: specs/013-platform-composition/{plan,research,tasks,quickstart}.md
- Follow-up TODOs:
  - CloudBrowser catalog maintenance requires separate explicit confirmation after release.
-->

# Terraform Any Analytics Repository Constitution

## Local Principles

### I. Bounded composition root

The repository root is the approved public composition module for the analytics
runtime suite. Runtime wrappers remain in `modules/<runtime>` and own their
own Helm release configuration. The root MUST NOT become a generic Helm-values
pass-through.

### II. Caller-owned prerequisites

This repository accepts only non-secret references to caller-created
prerequisites. Namespace creation, identity, databases and grants, object
storage, Redis, Secrets, ingress, DNS, TLS, and tenant data products remain
outside this repository.

### III. Releaseable consumer contract

Any root-interface change MUST keep typed variables, README, Terraform and YAML
examples, tests, generated documentation, and CI aligned. Terraform packages
MUST include a `.terraformignore` appropriate for release distribution.

## Shared Governance Source

Shared DasMeta governance is authoritative in
[`dasmeta/meta-level-constitution`](https://github.com/dasmeta/meta-level-constitution),
observed at `349db1f2f52185f41ef6ec4fe366752ef9bf5743`. This repository MUST
not restate or amend shared rules locally. A conflict is escalated to that
source rather than resolved by changing this file.

## Governance

This file contains repository-local constraints only. Amendments require a
reviewed pull request and matching downstream Spec Kit evidence.

**Version**: 1.1.0 | **Ratified**: 2026-07-30 | **Last Amended**: 2026-07-30
