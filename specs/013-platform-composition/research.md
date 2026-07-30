# Research: Analytics platform composition module

## Decision 1 — Compose local runtime modules

**Decision**: The repository root composes existing local Helm-wrapper modules
instead of recreating Helm releases or exposing raw Helm values.

**Why**: The children already encapsulate chart selection and runtime-specific
validation. A root pass-through would make the platform interface unstable and
would blur ownership between the platform and each service.

**Alternatives considered**:

- Reimplement each release in the root: rejected; duplicates runtime logic.
- Publish no root module and ask callers to compose child modules: rejected;
  every consumer would recreate selection, validation, and endpoint behavior.
- Use a cloud-provider module collection: not applicable; the requested
  capability is vendor-neutral Helm runtime composition, not cloud resource
  provisioning.

## Decision 2 — Root composition is a bounded layout exception

**Decision**: Use `.` as the public platform module and keep runtime modules in
`modules/<runtime>`.

**Why**: Operators need one source for a complete platform deployment and a
single YAML entry point. The user explicitly approved this structure.

**Boundary**: The root accepts only existing namespace and prerequisite
references. It does not add a shared Terraform dependency, create a namespace,
or claim ownership of Authentik, databases, storage, Redis, Secrets, ingress,
DNS, TLS, or tenant content.

## Decision 3 — One visualization provider

**Decision**: `visualization.provider` defaults to `metabase` when the object
is present and supports `redash` as the alternative. Validation requires only
the selected configuration block.

**Why**: It prevents accidental duplicate visualization releases while keeping
the default consumer path short.

## Decision 4 — Typed grouped inputs, no Helm escape hatch

**Decision**: Optional runtimes are nullable, typed grouped objects. The root
exposes neither secret values nor arbitrary chart values.

**Why**: Grouping matches each runtime's coherent contract, preserves child
module boundaries, and makes review of supported configuration possible.

## Capability and compatibility evidence

- Terraform module composition is an established language feature; the design
  follows the bounded composition approach in the
  [official Terraform module composition guidance](https://developer.hashicorp.com/terraform/language/modules/develop/composition).
- The module requires Terraform `~> 1.3` and the Helm provider `~> 3.0`, which
  support the object optionality and child-module composition used here.
- No deprecated provider capability, direct Kubernetes resource, or external
  cloud-provider resource is introduced by this feature.

## Retrospective workflow and catalog evidence

The composition root was implemented before Spec Kit was bootstrapped in this
downstream module repository. This is a bounded retrospective exception, not a
claim that the original implementation followed the required sequence. The
current package supplies the required specification, plan, tasks, validation,
and reconciliation evidence; review is the explicit acceptance gate.

CloudBrowser was read after the downstream evidence was available. Module
records exist for Metabase (ID 171, Kubernetes) and Redash (ID 129, Self
Managed), but not for Airbyte, dbt, or PostgREST. The catalog lacks confirmed
repository/version/documentation relations for the root composition module.
No catalog write is authorized by this feature; the bounded follow-up is to
propose those records and relations once a published platform version exists.
