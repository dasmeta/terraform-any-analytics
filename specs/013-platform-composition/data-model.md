# Data Model: Analytics platform composition module

This feature has a configuration contract rather than a persistent data model.
All values below are Terraform inputs or non-secret outputs.

## Inputs

| Input | Required | Shape | Responsibility |
|-------|----------|-------|----------------|
| `namespace` | Yes | non-empty string | Existing namespace supplied by caller. |
| `airbyte` | No | nullable object | Airbyte release, database reference, and object-storage reference. |
| `dbt` | No | nullable object | dbt CronJob image, command/schedule, and existing configuration Secret reference. |
| `postgrest` | No | nullable object | PostgREST release and existing configuration Secret reference. |
| `visualization` | No | nullable object | Provider selection plus exactly one Metabase or Redash configuration object. |

## Selection invariants

1. A `null` optional runtime omits its release.
2. `visualization = null` deploys neither visualization service.
3. When visualization is present, `provider` is `metabase` by default.
4. `provider = metabase` requires only `metabase`; `provider = redash` requires
   only `redash`.
5. No input contains a credential value. A Secret is named and interpreted by
   the runtime module; the caller creates it.

## Outputs

| Output | Shape | Meaning |
|--------|-------|---------|
| `service_endpoints` | map of service name/port objects | Internal HTTP endpoints for selected long-running runtimes. |
| `release_statuses` | map of strings | Helm release status for selected runtimes. |
| `visualization_provider` | string or null | The selected provider, or null if visualization is omitted. |

## YAML DSL projection

`examples/yaml/platform.yaml` projects the same public inputs into the IaC
DSL's standard form:

```yaml
source: dasmeta/analytics/any
version: "<released-platform-version>"
variables: {}
```

The company IaC repository supplies its own state/provider execution context
and replaces generic references with non-secret references created by the
appropriate prerequisite modules.
