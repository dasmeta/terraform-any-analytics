# Analytics YAML IaC DSL examples

These examples use the established DasMeta IaC DSL shape: `source`, `version`,
and `variables`. They are reference configuration roots for a customer's IaC
repository, not Kubernetes manifests and not a replacement for the Terraform
module examples.

Replace `<released-module-version>` with a released
`dasmeta/analytics/any` module version. The customer IaC repository supplies
the Helm provider's cluster context, remote-state configuration, and any
cross-component workspace links. Secrets are referenced by name only and must
already exist in the target namespace.

| Component | YAML example | Terraform module |
| --- | --- | --- |
| Standard platform suite | [platform.yaml](./platform.yaml) | repository root |
| Airbyte | [airbyte.yaml](./airbyte.yaml) | `modules/airbyte` |
| dbt | [dbt.yaml](./dbt.yaml) | `modules/dbt` |
| Metabase | [metabase.yaml](./metabase.yaml) | `modules/metabase` |
| PostgREST | [postgrest.yaml](./postgrest.yaml) | `modules/postgrest` |
| Redash | [redash.yaml](./redash.yaml) | `modules/redash` |

`platform.yaml` is the canonical one-entry-point example for the standard
runtime suite. Individual component files remain available when a component
needs independent state or release cadence. The customer IaC repository still
owns provider context and links to existing namespace, database, Secret,
ingress, DNS, and shared Authentik configuration.
