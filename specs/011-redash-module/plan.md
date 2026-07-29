# Implementation Plan: Redash Fallback Visualization Module

**Branch**: `011-redash-module`
**Module**: `modules/redash`

## Module contract

The module is a narrow direct-Kubernetes fallback because Redash has no maintained Helm chart and no approved cloud-provider module is applicable. It exposes namespace, workload name, one existing configuration Secret name, immutable image override, and server replica count. It intentionally does not pass arbitrary Redash values or create dependency services.

The configuration Secret is mounted read-only as four files. A small wrapper exports their values only in the process environment then `exec`s Redash's official entrypoint, preserving the official `create_db`, `server`, `scheduler`, and `worker` commands.

## Planned files

- `modules/redash/{main.tf,variables.tf,outputs.tf,versions.tf,README.md}`
- `modules/redash/examples/basic/main.tf`
- `modules/redash/tests/basic/{main.tf,providers.tf}`
- `.github/workflows/terraform-test.yaml`
- `specs/011-redash-module/{spec.md,research.md,plan.md,tasks.md}`

## Validation

Run formatting, module test init/validate/plan, Terraform documentation generation, Checkov, and whitespace checks. The package supplies the downstream Speckit gate evidence. This new module causes no breaking or interface-widening change.
