# Quickstart: Analytics Platform Delivery

1. Release the shared namespace and Authentik modules.
2. Release each analytics component module after its own Speckit package and
   validation evidence are complete.
3. Add one standard YAML Setup per released component in the customer's
   `2-products/data-analytics/<environment>/` directory.
4. Link to existing cluster, database, secret, ingress, and DNS Setups.
5. Run `meta validate-yaml`, regenerate the Terraform Cloud driver artifacts,
   commit/push them, and review the remote plan.
6. Only then create tenant-specific data-product configuration and Galust use
   cases.
