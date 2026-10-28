# terraform-free-trial-recreate

Terraform configuration that (re)creates a small set of objects in a Snowflake free-trial account, so the environment can be rebuilt from code after a trial expires.

## What it creates

| File | Resources |
| --- | --- |
| `snowflake_warehouses.tf` | `TF_UDEMY_WH` — XSMALL standard warehouse, auto-suspend 60s |
| `snowflake_databases_and_schemas.tf` | `test_db` database and its `BRONZE` schema |
| `snowflake_roles.tf` | `FINANCE_ANALYST` account role |
| `snowflake_users.tf` | One user, with the warehouse and role above as defaults |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) and network access to the Snowflake account
- A Snowflake service user (default name `TERRAFORM_SVC`) with key-pair authentication set up and permission to use the `SYSADMIN` and `ACCOUNTADMIN` roles
- The matching PKCS#8 private key (`.p8`) on your machine

## Authentication and providers

The Snowflake provider authenticates with key-pair JWT. Two provider configurations are defined in `main.tf`:

- **default** — role `SYSADMIN`, used for warehouses, databases and schemas
- **`provider_with_ACCOUNTADMIN`** — role `ACCOUNTADMIN`, used for roles and users

## Usage

1. Copy the example variables file and fill in your values:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

   | Variable | Description |
   | --- | --- |
   | `organization_name`, `account_name` | Snowflake account identifier parts |
   | `snowflake_user` | Service user Terraform logs in as |
   | `private_key_path` | Path to the `.p8` private key |
   | `login_name`, `first_name`, `middle_name` (optional), `last_name`, `email` | Details of the user to create |
   | `password` | Initial password for that user (sensitive) |

2. Run Terraform:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Security notes

`terraform.tfvars`, `*.tfstate` files, `.terraform/` and `*.p8` keys are gitignored. Never commit them: the state file can contain the user's password in plain text. State is stored locally; no remote backend is configured.
