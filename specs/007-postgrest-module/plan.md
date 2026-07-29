# Implementation Plan: PostgREST API runtime

Use direct Kubernetes `Deployment` and `Service` resources. PostgREST's
official distribution is a container image, not a maintained Helm chart, so
this is the bounded direct-resource fallback.

The module carries no database/JWT fields: the existing configuration Secret
contains a `postgrest.conf` file with the database URI and JWT/JWK settings.
Database schema and grants remain external because they define API behavior and
data authorization.

Default image is the official `postgrest/postgrest:v13.0.8`. Kubernetes owns
the process lifecycle; a separate ingress configuration uses service outputs.

The configuration Secret is mounted read-only rather than injected as
environment variables. The default image is pinned to the reviewed official
immutable digest; fixed conservative resource requests/limits and `Always`
image pull behavior are applied.
