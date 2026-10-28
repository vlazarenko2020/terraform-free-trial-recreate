
resource "snowflake_user" "firstname01_lastname01" {
  provider     = snowflake.provider_with_ACCOUNTADMIN # <--- Telling it to use the alias
  name         = var.login_name
  login_name   = var.login_name
  first_name   = var.first_name
  middle_name  = var.middle_name
  last_name    = var.last_name
  comment      = "User of snowflake."
  password     = var.password
  disabled     = "false"
  display_name = var.login_name
  email        = var.email

  default_warehouse              = snowflake_warehouse.tf_udemy_wh.fully_qualified_name
  default_secondary_roles_option = "ALL"
  default_role                   = snowflake_account_role.finance_analyst.fully_qualified_name
  default_namespace              = "some.namespace"

  mins_to_unlock     = 9
  days_to_expiry     = 8
  mins_to_bypass_mfa = 10

  # rsa_public_key   = "..."
  # rsa_public_key_2 = "..."

  must_change_password = "true"
  disable_mfa          = "false"
}
