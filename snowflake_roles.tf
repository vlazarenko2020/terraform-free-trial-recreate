
## Complete (with every optional set)
resource "snowflake_account_role" "finance_analyst" {
  provider = snowflake.provider_with_ACCOUNTADMIN # <--- Telling it to use the alias
  name     = "FINANCE_ANALYST"
  comment  = "Finance Analyst Role"
}