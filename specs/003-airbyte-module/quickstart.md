# Quickstart: Airbyte module

1. Create a namespace through the shared namespace module.
2. Use the standard database capability to create the Airbyte database, user,
   and grants.
3. Create a database Secret with the configured username/password keys.
4. Provision an AWS S3 bucket and create an S3 credential Secret with the
   configured access-key/secret-access-key keys.
5. Apply `modules/airbyte` with only Secret names and non-secret endpoint
   metadata.
6. Configure the standard ingress module against `webapp_service_name` and
   `webapp_service_port`; use Authentik as the ingress proxy.
7. Define Airbyte sources, destinations, connections, and schedules in the
   tenant data-product repository—not in this module.
