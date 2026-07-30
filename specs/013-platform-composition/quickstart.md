# Quickstart: Verify the analytics platform composition module

Run these commands from the repository root. They require the current asdf
Terraform selection (1.15.8 during this feature) and do not require cluster
access or a Terraform backend.

```sh
asdf exec terraform fmt -check -recursive
asdf exec terraform init -backend=false
asdf exec terraform -chdir=examples/basic init -backend=false
asdf exec terraform -chdir=examples/basic validate
asdf exec terraform -chdir=tests/basic init -backend=false
asdf exec terraform -chdir=tests/basic validate
asdf exec terraform test
terraform-docs markdown table --output-file README.md --output-mode inject .
ruby -e 'require "yaml"; YAML.load_file("examples/yaml/platform.yaml")'
git diff --check
```

The consumer then copies `examples/yaml/platform.yaml` into its company IaC
configuration repository, pins `version` to a released platform version, and
sets only its existing namespace and non-secret prerequisite references.

## Verification record

The following completed successfully for the current root composition module:

- `asdf exec terraform fmt -check -recursive`.
- Root, `examples/basic`, and `tests/basic` initialization/validation.
- `asdf exec terraform test`: invalid provider, ambiguous configuration,
  missing selected-provider configuration, omitted visualization, Redash-only
  selection, and the complete default-Metabase runtime suite (six cases),
  including selected-only `release_statuses` output keys.
- `terraform-docs` root README generation.
- Ruby YAML parsing and `git diff --check`.
- `checkov -d . --quiet`: passed. Checkov emitted only an external guidance
  refresh warning when sandbox DNS could not reach Prismacloud.

## Spec Kit reconciliation

The prerequisite check recognizes the active feature package and its design
documents. The actual Clarify → Plan → Tasks → Analyze → Implement chain is
complete. Clarify found no critical ambiguity. Read-only analysis found and
the Implement stage corrected one meaningful gap: the tests proved selected
endpoints but not selected-only release-status keys. The workflow also
corrected duplicated local governance, incomplete retrospective/CloudBrowser
evidence, a missing `.terraformignore`, and imprecise README ownership wording.
No public input, output, provider constraint, child module, chart version, or
customer IaC YAML contract changed.

The remaining review decision is acceptance of the documented retrospective
Spec Kit bootstrap exception. Future module-impacting work must start with the
normal Spec Kit sequence.
