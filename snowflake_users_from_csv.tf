
# 1. Read and parse the CSV file into a map, keyed by the login_name
locals {
  users_data = csvdecode(file("${path.module}/csv/users-finance.csv"))
}

# csvdecode(...): Takes that raw text and converts it into a list of maps, where each row becomes a dictionary 
# for example: 
# [ 
#     {first_name = "John", last_name = "Doe" ...}, 
#    {...} 
# ]



# 2. Create the users dynamically using for_each
resource "snowflake_user" "bulk_users" {
  provider = snowflake.provider_with_ACCOUNTADMIN

  # Dynamically construct the key and login_name as FIRST_LAST
  for_each = { for user in local.users_data : upper("${user.first_name}_${user.last_name}") => user }
  #      ^                                                                                      ^
  #      ^                                                                                      ^
  # The curly braces {} are the exact syntax in Terraform that tell it: "Take the results of this loop and build a Map (an object/dictionary)."
  # each.key evaluates to "JOHN_DOE", "JANE_SMITH", etc.

  name       = each.key
  login_name = each.key
  first_name = each.value.first_name
  last_name  = each.value.last_name
  email      = each.value.email


  comment      = "Finance User Provisioned via CSV and Terraform"
  password     = var.default_password # You can pull a shared password from a variable
  disabled     = "false"
  display_name = "${each.value.first_name} ${each.value.last_name}"

  default_warehouse              = snowflake_warehouse.tf_udemy_wh.fully_qualified_name
  default_secondary_roles_option = "ALL"
  default_role                   = snowflake_account_role.finance_analyst.fully_qualified_name
  default_namespace              = "some.namespace"

  mins_to_unlock       = 9
  days_to_expiry       = 8
  mins_to_bypass_mfa   = 10
  must_change_password = "true"
  disable_mfa          = "false"
}