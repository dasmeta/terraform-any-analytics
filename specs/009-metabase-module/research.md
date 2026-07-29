# Research: Metabase Module

## Decision: direct Kubernetes resources rather than Helm

The former Metabase Helm repository endpoint (`https://www.metabase.com/helm/index.yaml`) returned HTTP 404 on 2026-07-29. No provider-maintained Terraform module exists in the approved AWS, Azure, or Google collections because Metabase is a Kubernetes application rather than a cloud resource. The module therefore uses direct Kubernetes resources and the official `metabase/metabase` image.

## Decision: external PostgreSQL application database

Metabase documents PostgreSQL as the production application database and states that it does not create the database. It supports a JDBC connection URI and its official container entrypoint supports `MB_DB_CONNECTION_URI_FILE`. The module mounts an existing Secret's `MB_DB_CONNECTION_URI` key as a file, sets `MB_DB_CONNECTION_URI_FILE`, and does not provision any database object.

Sources:

- https://www.metabase.com/docs/latest/installation-and-operation/configuring-application-database
- https://www.metabase.com/docs/latest/installation-and-operation/running-metabase-on-docker

## Decision: image and runtime defaults

The official image tag `v0.63.1.12` was resolved to the immutable multi-architecture manifest digest `sha256:a6e4100e913165ab2f2d5ac36bc1a2f63edd0ff5b2292e7a10642351598e1de7` on 2026-07-29. The Metabase image entrypoint supports non-root execution and uses uid/gid 2000 when it starts from root, so the module runs as uid/gid 2000 and drops all capabilities. The workload uses a read-only root filesystem and an ephemeral `/tmp` volume as its working directory; no persistent local state is relied on because PostgreSQL is mandatory.

Source: https://github.com/metabase/metabase/blob/master/bin/docker/run_metabase.sh

## Decision: one replica by default

Metabase documentation directs clustered upgrades to reduce to a single node while migrations run. The module therefore defaults to one replica. Scaling is an intentional operator action after an upgrade strategy is established.

Source: https://www.metabase.com/docs/latest/installation-and-operation/upgrading-metabase

## Modern capabilities classification

| Ability | Classification | Basis |
| --- | --- | --- |
| Kubernetes Deployment and ClusterIP Service | supported | Kubernetes provider v2.33 supports `kubernetes_deployment_v1` and `kubernetes_service_v1`. |
| Kubernetes workload security context | supported | Provider schema supports pod/container security contexts without deprecated APIs. |
| External PostgreSQL application database | supported | Metabase production documentation prescribes PostgreSQL configuration through `MB_DB_*`. |

## Boundaries

- No database, role, grant, namespace, Secret, ingress, dashboard, collection, data-source, or Authentik resource is created.
- Dashboard content belongs to a tenant data product and native Metabase setup remains a component-owned operation.
- Ingress and Authentik forward-auth integration belongs to the gateway/platform composition layer.
