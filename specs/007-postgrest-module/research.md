# Research: PostgREST runtime

- Official PostgREST 13 configuration documents `PGRST_DB_URI` and
  `PGRST_JWT_SECRET`/JWK configuration as environment variables.
  <https://docs.postgrest.org/en/v13/references/configuration.html>
- PostgREST external authentication maps a valid JWT role claim to a database
  role; database grants and schema remain the authorization source.
  <https://docs.postgrest.org/en/v13/references/auth.html>
- Official v13.0.8 image digest selected:
  `postgrest/postgrest@sha256:d09618df2b7b9547c80a076c2f4045b326be8d7ac06060d263caefec1334e3c9`.
