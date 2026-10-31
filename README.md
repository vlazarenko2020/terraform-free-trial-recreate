# terraform-free-trial-recreate

Terraform configuration that (re)creates a set of objects in a Snowflake free-trial account, so the environment can be rebuilt from code after a trial expires. Changes are applied either locally or by a GitHub Actions workflow.

## What it creates

| File | Resources |
| --- | --- |
| `snowflake_warehouses.tf` | `TF_UDEMY_WH` — XSMALL standard warehouse, auto-suspend 60s |
| `snowflake_databases_and_schemas.tf` | `test_db` database and its `BRONZE` schema |
| `dbt_project.tf` | `tasty_bytes_dbt_db` database; one schema per row of `csv/dbt_project_schemas.csv` (bronze, silver, gold) |
| `snowflake_roles.tf` | `FINANCE_ANALYST` account role |
| `snowflake_users.tf` | One user (details from variables), with the warehouse and role above as defaults |
| `snowflake_users_from_yaml.tf` | One user per entry in `yaml/users-finance.yml`, all sharing `default_password` |

To add a user, add an entry to `yaml/users-finance.yml`; to add a schema, add a row to `csv/dbt_project_schemas.csv`. No `.tf` change is needed. Users must change their password at first login.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) 1.10 or newer (the S3 backend uses native lockfile locking)
- A Snowflake service user (default name `TERRAFORM_SVC`) with key-pair authentication set up and permission to use the `SYSADMIN` and `ACCOUNTADMIN` roles
- The matching PKCS#8 private key (`.p8`) on your machine
- AWS credentials with access to the S3 bucket that holds the state

## Authentication and providers

The Snowflake provider authenticates with key-pair JWT. Two provider configurations are defined in `main.tf`:

- **default** — role `SYSADMIN`, used for warehouses, databases and schemas
- **`provider_with_ACCOUNTADMIN`** — role `ACCOUNTADMIN`, used for roles and users

## State

State is stored remotely in an S3 bucket (key `snowflake/users-project/terraform.tfstate`) with `use_lockfile` locking. The bucket name and region are set in the `backend "s3"` block in `main.tf`; change them there when using your own bucket.

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
   | `login_name`, `first_name`, `middle_name` (optional), `last_name`, `email` | Details of the single user in `snowflake_users.tf` |
   | `password` | Initial password for that user (sensitive) |
   | `default_password` | Shared initial password for all users created from the YAML file (sensitive) |

2. Run Terraform:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## CI/CD

`.github/workflows/terraform.yml` runs on pushes and pull requests to `main`: `init`, `validate`, then `plan`. On a push to `main` it also runs `terraform apply -auto-approve`, so merging to `main` changes the live Snowflake account.

The workflow reads these GitHub Secrets: `SNOWFLAKE_ORGANIZATION_NAME`, `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, `SNOWFLAKE_PRIVATE_KEY` (base64-encoded `.p8` file), `SNOWFLAKE_PRIVATE_KEY_PASSPHRASE`, `TMP_LOGIN_NAME`, `TMP_FIRST_NAME`, `TMP_LAST_NAME`, `TMP_EMAIL`, `TMP_PASSWORD`, `TMP_DEFAULT_PASSWORD`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_REGION`.

## Security notes

`terraform.tfvars`, local `*.tfstate` files, `.terraform/` and `*.p8` keys are gitignored. Never commit them. Passwords for the created users are stored in the Terraform state, so keep the S3 bucket private and encrypted.
