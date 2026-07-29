# Analytics YAML IaC DSL examples

These examples use the established DasMeta IaC DSL shape: `source`, `version`,
and `variables`. They are reference component roots for a customer's IaC
configuration repository, not Kubernetes manifests and not a replacement for
the Terraform module examples.

Replace `<released-module-version>` with a released
`dasmeta/analytics/any` module version. The customer IaC repository supplies
the Helm provider's cluster context, remote-state configuration, and any
cross-component workspace links. Secrets are referenced by name only and must
already exist in the target namespace.

| Component | YAML example | Terraform module |
| --- | --- | --- |
| Airbyte | [airbyte.yaml](./airbyte.yaml) | `modules/airbyte` |
| dbt | [dbt.yaml](./dbt.yaml) | `modules/dbt` |
| Metabase | [metabase.yaml](./metabase.yaml) | `modules/metabase` |
| PostgREST | [postgrest.yaml](./postgrest.yaml) | `modules/postgrest` |
| Redash | [redash.yaml](./redash.yaml) | `modules/redash` |

The YAML examples intentionally deploy independent module roots. A customer
platform root composes only the selected components and the customer's existing
namespace, database, secrets, provider, and ingress configuration.
