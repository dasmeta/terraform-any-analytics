# Research: Redash Module

## Official runtime topology

Redash's maintained setup repository defines five runtime services: `server`, `scheduler`, `scheduled_worker`, `adhoc_worker`, and `worker`. The workers use distinct queues and worker counts. Redash documents that it needs PostgreSQL and Redis, and its image supports Kubernetes/container orchestration.

Sources:

- https://github.com/getredash/setup/blob/master/data/compose.yaml
- https://redash.io/help/open-source/setup/

## Native initialization

The Redash v26.3.0 image entrypoint exposes `create_db`, which runs `manage.py database create_tables`. The module creates a bounded Kubernetes Job using that command and makes runtime deployments depend on it. This uses Redash's own initialization capability rather than substituting custom SQL.

Source: https://github.com/getredash/redash/blob/v26.3.0/bin/docker-entrypoint

## Configuration and security decision

Redash v26.3.0 reads its PostgreSQL URL, Redis URL, cookie secret, and data-source secret from environment variables; its settings do not offer `_FILE` variants. The module mounts one existing Secret as files and uses a minimal shell wrapper only to export those file contents before executing the official `/app/bin/docker-entrypoint` command. This is a bounded interoperability layer, not a replacement for Redash-native behavior.

The v26.3.0 official multi-architecture manifest digest is `sha256:c5c9148f5c389c9373224bde7053b4a1652fd696ee881dce00a064d21ccdcba8` (resolved 2026-07-29). The release Dockerfile runs as the non-root `redash` user.

Source: https://github.com/getredash/redash/blob/v26.3.0/Dockerfile

## Sourcing and modern capabilities

No approved cloud-provider module applies and Redash provides no maintained Helm chart. Direct Kubernetes resources are the bounded fallback. Kubernetes `kubernetes_job_v1`, `kubernetes_deployment_v1`, and `kubernetes_service_v1` are supported by the repository's Kubernetes provider constraint. The module uses supported non-deprecated resource versions, Secret volume mounts, security contexts, and ClusterIP Services.

## Scope exclusions

- PostgreSQL, Redis, namespace, Secret, ingress/gateway, TLS, and Authentik provisioning.
- Redash custom query runner/image builds, dashboards, users, data sources, alerts, and email configuration.
