# Research: dbt runner

- dbt Core is intended to run from a project environment; the tenant image is
  therefore the right ownership boundary for models, dependencies, and profiles.
  Reference: <https://docs.getdbt.com/docs/core/installation-overview>.
- Kubernetes `batch/v1` CronJobs provide scheduled execution and can be used as
  the source of one-off Jobs without a second orchestration mechanism.
  Reference: <https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/>.
- No official dbt Helm chart was selected because this capability is one
  containerized data-product execution, not a long-lived dbt service.
