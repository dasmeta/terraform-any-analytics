# Data Model: Platform Composition

| Entity | Owner | Required relationship |
| --- | --- | --- |
| Shared namespace | `terraform-any-shared` | Consumed by every analytics module. |
| Identity runtime | `terraform-any-shared` | Supplies access boundary for exposed UIs/APIs. |
| Analytics component | `terraform-any-analytics` | One module/state per service. |
| Database interface | standard database capability | Pre-created; referenced by service configuration. |
| Secret reference | customer secret capability | Pre-created; referenced, never inlined. |
| YAML Setup | customer IaC repo | Pins one released module and declares dependencies. |
| Tenant data product | tenant fork | Selects approved capabilities, sources, mappings, dashboards, AI use cases. |
