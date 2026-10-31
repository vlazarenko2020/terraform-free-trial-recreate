# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Flat Terraform root module that (re)creates objects in a Snowflake free-trial account using the `snowflakedb/snowflake` provider (no version pinned; see `.terraform.lock.hcl`). No tests or build step. `README.md` documents resources, variables and CI for humans.

## Commands

```
terraform init
terraform fmt -check      # a local, gitignored terraform.tfvars may be flagged; ignore it
terraform validate
terraform plan
terraform apply
```

`init` and `plan` need AWS credentials (S3 backend) as well as the Snowflake key.

Required variables (`variables.tf`): `organization_name`, `account_name`, `snowflake_user`, `private_key_path`, `login_name`, `first_name`, `last_name`, `email`, `password` and `default_password` (both sensitive); `middle_name` is optional. `terraform.tfvars.example` lists them all with placeholders (copy it to `terraform.tfvars`). Supply via a `*.tfvars` file (gitignored), `-var`, or `TF_VAR_*`.

## Architecture

- `main.tf` holds the provider config and the backend. Account identifiers, service user and private key path come from variables (real values live in the gitignored `terraform.tfvars`). Auth is key-pair JWT as the `snowflake_user` (`TERRAFORM_SVC`), so the `.p8` key must exist locally for any plan/apply.
- State is remote: S3 backend with `use_lockfile` (needs Terraform 1.10+). The bucket name is hardcoded in `main.tf`. Local `*.tfstate` is gitignored.
- Two provider configurations: the default one uses role `SYSADMIN`; the alias `snowflake.provider_with_ACCOUNTADMIN` uses `ACCOUNTADMIN`. Resources that need account-level privileges (roles, users) must set `provider = snowflake.provider_with_ACCOUNTADMIN` explicitly. Warehouses, databases and schemas use the default SYSADMIN provider.
- One resource family per file (`snowflake_<kind>.tf`). Cross-file references use `fully_qualified_name`, e.g. the user in `snowflake_users.tf` takes its default warehouse and role from `snowflake_warehouse.tf_udemy_wh` and `snowflake_account_role.finance_analyst`.
- Bulk resources are driven by CSV files in `csv/` via `csvdecode` + `for_each`: `snowflake_users_from_csv.tf` reads `users-finance.csv` (users keyed `FIRST_LAST`, all sharing `var.default_password`) and `dbt_project.tf` reads `dbt_project_schemas.csv` (schemas keyed `<DB>_<SCHEMA>`). Adding a row adds a resource; changing the key columns replaces it.
- CI (`.github/workflows/terraform.yml`) runs validate and plan on PRs to `main`, and `apply -auto-approve` on every push to `main`. It receives all variables as `TF_VAR_*` from GitHub Secrets, so a new required variable must also be added to the workflow's `env` and to the repo secrets, or CI will fail.
