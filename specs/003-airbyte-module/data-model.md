# Data model: Airbyte module

## External database

| Field | Meaning |
|---|---|
| `host`, `name`, `port` | Existing PostgreSQL endpoint metadata. |
| `secret_name` | Existing Secret in the target namespace. |
| `user_secret_key`, `password_secret_key` | Database credential keys in that Secret. |

## External S3 storage

| Field | Meaning |
|---|---|
| `bucket` | One existing bucket for all Airbyte storage classes. |
| `region` | AWS region used by the Airbyte S3 client. |
| `secret_name` | Existing Secret in the target namespace. |
| credential key names | Configurable access-key and secret-access-key keys in that Secret. |

## Outputs

The module returns Helm release identity/status/version plus the deterministic
ClusterIP webapp endpoint `<release>-airbyte-webapp-svc:80`.
