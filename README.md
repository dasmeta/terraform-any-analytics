<p align="center">
  <a href="https://www.dasmeta.com">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://a.storyblok.com/f/295271/424783ac50/dasmeta-wordmark-light.png">
      <source media="(prefers-color-scheme: light)" srcset="https://a.storyblok.com/f/295271/5938d2b888/dasmeta-wordmark-dark.png">
      <img src="https://a.storyblok.com/f/295271/5938d2b888/dasmeta-wordmark-dark.png" alt="Das Meta" width="220">
    </picture>
  </a>
</p>

# terraform-any-analytics

Terraform modules that install selected analytics-platform runtimes into an
existing Kubernetes namespace using version-pinned Helm charts.

**Current delivery state (verified 2026-07-30):** this repository has no
published GitHub release. The YAML examples contain a
`<released-module-version>` placeholder and cannot be applied unchanged until a
module release is published.

**Compatibility:** Terraform `~> 1.3` and the HashiCorp Helm provider `~> 3.0`.
Each module requires an existing Kubernetes namespace and a configured Helm
provider context.

## Which analytics runtime should I use?

Choose and compose only the modules required by the platform. This repository
does not provide a single all-in-one platform module.

| Module | Use it for | Runtime dependency owned outside this module |
| --- | --- | --- |
| [Airbyte](./modules/airbyte/) | ingesting data with the official Airbyte Helm chart | PostgreSQL, S3 bucket, and database/storage Secrets |
| [dbt](./modules/dbt/) | scheduling a data-product-owned dbt image | configuration Secret and the image's dbt project and warehouse access |
| [PostgREST](./modules/postgrest/) | exposing a prepared PostgreSQL schema as an internal API | database roles, grants, API schema/views/functions, and `PGRST_*` Secret |
| [Metabase](./modules/metabase/) | the default visualization provider | PostgreSQL application database, user/grants, and connection Secret |
| [Redash](./modules/redash/) | a fallback visualization provider | PostgreSQL, Redis, and configuration Secret |

Metabase and Redash are alternatives for visualization; they are not both
required. Airbyte and dbt do not configure source connections, transformations,
models, mappings, or schedules beyond the dbt command and CronJob schedule
provided to the module.

## What does this repository manage?

Each module creates a `helm_release` and a private ClusterIP service or CronJob
where its chart provides one. The caller provides the surrounding platform
contracts:

1. Provision the namespace, databases, users, grants, storage, Redis, and
   Kubernetes Secrets through the platform's database and secrets layers.
2. Configure the Helm provider for the target cluster, then instantiate the
   selected module roots.
3. Configure Gateway/ingress, DNS, TLS, Authentik policy, and Galust access
   separately using the service outputs exposed by the relevant module.
4. Configure tenant data-product content in its native tool: Airbyte sources
   and connections, dbt models, PostgREST API schema, and visualization users,
   queries, and dashboards.

Terraform receives Secret names and key names only. It does not create or store
credential values.

## How do I evaluate a module before a release is published?

The repository's verified local check validates each basic module fixture
without a Kubernetes cluster or backend:

```sh
terraform fmt -check -recursive

for module in modules/airbyte modules/dbt modules/postgrest modules/metabase modules/redash; do
  terraform -chdir="$module/tests/basic" init -backend=false
  terraform -chdir="$module/tests/basic" validate
done
```

The GitHub Actions workflow runs the same `init -backend=false` and `validate`
steps with Terraform 1.15.8. Validation checks module syntax and provider
contracts; it does not install a chart or prove that caller-managed runtime
dependencies exist.

For a component-specific Terraform configuration, start with its
[basic example](./modules/airbyte/examples/basic/) and read that module's
README before applying it. The examples expect caller-managed prerequisites and
do not contain production credentials.

## Can I use the YAML examples in a customer IaC repository?

Yes, as reference configurations. The
[YAML IaC DSL examples](./examples/yaml/) use the established DasMeta
`source`, `version`, and `variables` shape. Copy only the selected component
root to the customer's IaC configuration repository, replace
`<released-module-version>` after a release is available, and retain the
customer repository's provider, remote-state, and composition configuration.

The YAML files are not Kubernetes manifests and do not replace the Terraform
examples. They deliberately reference existing Secrets by name and use neutral
example values.

## What is intentionally out of scope?

These modules do not:

- provision Kubernetes namespaces, databases, database users, grants, buckets,
  Redis, or credential values;
- configure Gateway/ingress, DNS, TLS, or Authentik forward-auth;
- create Airbyte sources, destinations, connections, mappings, or schedules;
- build dbt images or copy dbt projects into containers;
- define PostgREST database schemas, roles, grants, views, or functions; or
- create Metabase or Redash users, data sources, queries, dashboards, alerts,
  or email configuration.

Use the owning platform layer or the native application for those concerns.

## Where is the canonical documentation for each concern?

| Question | Canonical location |
| --- | --- |
| Repository purpose, module selection, boundaries, and validated entry point | this README |
| Component inputs, outputs, chart versions, operational notes, and service names | the relevant [module README](./modules/) |
| Terraform configuration shape | each module's [basic example](./modules/airbyte/examples/basic/) |
| Customer IaC DSL shape | [YAML examples](./examples/yaml/) |
| Executable validation contract | [basic tests](./modules/) and [Terraform validation workflow](./.github/workflows/terraform-test.yaml) |
| License terms | [Apache License 2.0](./LICENSE) |

This repository currently has no published `CONTRIBUTING.md`, `SECURITY.md`,
`SUPPORT.md`, or `CHANGELOG.md`. Repository-owner confirmation is required
before claiming a contribution process, security-reporting route, support SLA,
or release-versioning policy.

---

<p align="center">
  Created by <a href="https://github.com/dasmeta">DasMeta</a> ·
  <a href="https://github.com/dasmeta/terraform-any-analytics/issues">Issues</a> ·
  <a href="./LICENSE">Apache-2.0 License</a>
</p>
