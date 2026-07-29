# Implementation Plan: Default Metabase Visualization Module

**Branch**: `009-metabase-module`
**Module**: `modules/metabase`

## Repository and interface assessment

The analytics repository already uses a narrow, direct Kubernetes-resource pattern for PostgREST and a Helm wrapper only when an actively maintained official application chart exists. The Metabase chart endpoint is unavailable, so direct resources are the bounded fallback. Existing repository conventions keep provider requirements in `versions.tf`, use separate `main.tf`, `variables.tf`, `outputs.tf`, README, executable example, and Terraform test fixture.

The interface remains intentionally narrow and flat: `namespace`, `application_database_secret_name`, and optional workload naming/replicas/image. Grouping would add no clarity because every field refers to a different Kubernetes resource or lifecycle concern. No client-specific name or hostname is introduced.

## Wrapper and sourcing assessment

No approved cloud-provider module is applicable. No maintained official Helm chart endpoint is available. The local module adds an opinionated deployment contract around Metabase's official image: immutable image pinning, external database-only setup, ClusterIP-only networking, health checks, resource defaults, and workload hardening. It intentionally does not pass arbitrary environment variables or Helm values.

The downstream Speckit package is `specs/009-metabase-module/`; it provides `spec.md`, this plan, tasks, and research evidence for the module-change gate.

## Planned files

- `modules/metabase/{main.tf,variables.tf,outputs.tf,versions.tf,README.md}`
- `modules/metabase/examples/basic/main.tf`
- `modules/metabase/tests/basic/{0-setup.tf,1-example.tf,2-assert.tf}`
- `.github/workflows/terraform-test.yaml` (add the module to the established matrix)

## Implementation details

1. Create a Kubernetes Deployment configured with an immutable official image, port 3000, `/api/health` probes, one replica by default, no service-account token, and constrained resources/security context.
2. Load the externally created application database Secret using `env_from`; documented required keys are the Metabase `MB_DB_*` variables.
3. Create only a ClusterIP Service on port 3000 and output its name and port.
4. Provide example/test inputs that use generic placeholders and establish no external infrastructure.
5. Generate Terraform documentation and run formatting, validation, no-change plan, and Checkov.

## Compatibility and approval assessment

This is a new module with no breaking existing interface. It does not widen an existing interface and does not create an alternate configuration pass-through. There are no unresolved conflicts requiring approval.

## Scope exclusions

- PostgreSQL database/users/grants/Secret creation.
- Namespace, ingress/gateway, TLS, and Authentik configuration.
- Metabase dashboards, collections, data-source setup, and initial admin account.
- Metabase high-availability and upgrade orchestration.
