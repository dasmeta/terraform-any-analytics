# Research: Analytics Platform Delivery Baseline

## Confirmed Architecture Decisions

- Component modules and customer YAML Setups are separate states; a production
  platform must not be one all-in-one Terraform state.
- Namespace and Authentik are shared cross-domain capabilities, owned by
  `terraform-any-shared`.
- Airbyte, dbt runner, PostgREST, Metabase, and Redash are analytics
  capabilities, owned by `terraform-any-analytics`.
- The customer IaC contract remains the existing DasMeta YAML DSL. Terraform
  source belongs only in module repositories.
- Databases, users, and grants are pre-created by standard database
  capabilities. Analytics modules consume their interfaces.
- Metabase is the default visualisation runtime; Redash is an alternative.
- Galust is SaaS and consumes governed APIs/MCPs; it is not provisioned here.

## Open Module-Level Research

Each service needs a separate package because its chart/image support,
licensing, storage, database, ingress, and initialization contracts differ.
No module source is selected until its package records official upstream
evidence and a narrow wrapper decision.
