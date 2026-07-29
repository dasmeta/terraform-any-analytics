# Feature Specification: PostgREST API runtime

**Feature Branch**: `007-postgrest-module`
**Created**: 2026-07-29

Deploy official PostgREST as a Kubernetes Deployment and ClusterIP Service over
a pre-created API schema. The runtime consumes an existing namespace and Secret
holding a complete `postgrest.conf`, including the database URI and JWT/JWK
verification configuration. It never creates database infrastructure, roles,
grants, schemas, views, functions, Secret values, ingress, or API content.

## Requirements

- Use the reviewed immutable official PostgREST v13.0.8 image digest and port 3000 internally.
- Mount the supplied existing Secret read-only as `/etc/postgrest/postgrest.conf`.
- Create a ClusterIP Service and expose non-secret Service outputs for a
  separate ingress or Galust API client.
- Use health probes, non-overlapping narrow Kubernetes resources, and secure
  pod defaults.
- Do not expose generic Deployment spec or arbitrary PostgREST config inputs.
- Include Speckit evidence, example, fixture, documentation, and CI coverage.

## Success criteria

A Terraform plan contains exactly the runtime Deployment and Service with no
credential values. The published Secret contract is sufficient for PostgREST to
connect to the externally managed database and verify access tokens.
