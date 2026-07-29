# Tasks: Helm-only Analytics Workloads

- [x] T001 Confirm released chart versions and component capabilities.
- [x] T002 Update Speckit requirements and plan for released component charts.
- [x] T003 Replace dbt with a `base-cronjob` Helm release.
- [x] T004 Replace Metabase and PostgREST with their released component-chart Helm releases.
- [x] T005 Replace Redash with its released topology chart Helm release.
- [x] T006 Update examples, tests, documentation, and outputs for every affected module.
- [ ] T007 Run formatting, Terraform validation, chart rendering, and publish the corrective branch. Terraform provider schema validation is environment-blocked by Helm v3.2.0 on the local Terraform v1.15.4 arm64 runtime; formatting, provider declarations, and released-chart rendering are complete.
