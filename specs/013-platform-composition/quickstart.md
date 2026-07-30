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
  omitted visualization, and Redash-only selection.
- `terraform-docs` root README generation.
- Ruby YAML parsing and `git diff --check`.
- `checkov -d . --quiet`: passed. Checkov emitted only an external guidance
  refresh warning when sandbox DNS could not reach Prismacloud.

The generated Spec Kit prerequisite check is run after this package's plan and
tasks are present; its result is recorded with the pull request update.
