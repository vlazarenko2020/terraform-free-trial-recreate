# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Flat Terraform root module that (re)creates objects in a Snowflake free-trial account using the `snowflakedb/snowflake` provider (no version pinned; see `.terraform.lock.hcl`). No tests or build step. README is just a title.

## Commands

```
terraform init
terraform fmt -check      # many files are currently not fmt-clean
terraform validate
terraform plan
terraform apply
```

Required variables (`variables.tf`): `organization_name`, `account_name`, `snowflake_user`, `private_key_path`, `login_name`, `first_name`, `last_name`, `email`, `password` (sensitive); `middle_name` is optional. `terraform.tfvars.example` lists them all with placeholders (copy it to `terraform.tfvars`). Supply via a `*.tfvars` file (gitignored), `-var`, or `TF_VAR_*`.

## Architecture

- `main.tf` holds the provider config. Account identifiers, service user and private key path come from variables (real values live in the gitignored `terraform.tfvars`). Auth is key-pair JWT as the `snowflake_user` (`TERRAFORM_SVC`), so the `.p8` key must exist locally for any plan/apply.
- Two provider configurations: the default one uses role `SYSADMIN`; the alias `snowflake.provider_with_ACCOUNTADMIN` uses `ACCOUNTADMIN`. Resources that need account-level privileges (roles, users) must set `provider = snowflake.provider_with_ACCOUNTADMIN` explicitly. Warehouses, databases and schemas use the default SYSADMIN provider.
- One resource family per file (`snowflake_<kind>.tf`). Cross-file references use `fully_qualified_name`, e.g. the user in `snowflake_users.tf` takes its default warehouse and role from `snowflake_warehouse.tf_udemy_wh` and `snowflake_account_role.finance_analyst`.
- State is local (no backend configured); `*.tfstate` is gitignored.
