terraform {
  required_providers {
    snowflake = {
      source = "snowflakedb/snowflake"
    }
  }
}

provider "snowflake" {
  organization_name = var.organization_name
  account_name      = var.account_name
  user              = var.snowflake_user
  role              = "SYSADMIN"
  authenticator     = "SNOWFLAKE_JWT"
  private_key       = file(pathexpand(var.private_key_path))
}

# 2. Secondary Provider with an Alias (using ACCOUNTADMIN)
provider "snowflake" {
  alias             = "provider_with_ACCOUNTADMIN" # <--- The alias name
  organization_name = var.organization_name
  account_name      = var.account_name
  user              = var.snowflake_user
  role              = "ACCOUNTADMIN" # Elevated role for admin tasks
  authenticator     = "SNOWFLAKE_JWT"
  private_key       = file(pathexpand(var.private_key_path))
}
