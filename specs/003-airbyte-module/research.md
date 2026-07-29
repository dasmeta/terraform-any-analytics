# Research: Airbyte module

- Official chart repository: <https://airbytehq.github.io/helm-charts>.
- Current inspected chart: `airbyte` `1.9.2`, app version
  `2.0.2-alpha-c905e75`.
- `global.database.secretName`, `userSecretKey`, and `passwordSecretKey` render
  database credential `secretKeyRef` values; `postgresql.enabled=false` selects
  external database behavior.
- `global.storage.type=s3` avoids the chart's `minio.yaml`, which is guarded by
  storage type `minio` and creates a StatefulSet/PVC.
- S3 credentials are rendered from `global.storage.secretName` and the
  configured access-key Secret keys.
- The chart's Keycloak and Keycloak setup components default to enabled. Their
  published values do not provide a stable external Authentik/OIDC contract;
  retaining them is the lowest-risk current runtime choice while Authentik
  remains the ingress proxy.
