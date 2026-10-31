# terraform {
#   required_providers {
#     snowflake = {
#       source = "snowflakedb/snowflake"
#     }
#   }
# }

terraform {
  required_providers {
    snowflake = {
      source = "snowflakedb/snowflake"
    }
  }
  backend "s3" {
    bucket       = "terraform-900123204721-us-east-2-an"
    key          = "snowflake/users-project/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true # <--- Replaces dynamodb_table
    #   dynamodb_table = "terraform-state-locks"  # no longer needed if using "use_lockfile = true"
    #   profile        = "your-aws-profile-name" # Optional: remove if you use export AWS_PROFILE
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
