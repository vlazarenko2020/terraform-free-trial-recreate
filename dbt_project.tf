

resource "snowflake_database" "terraform_tasty_bytes_dbt_db" {
  name                        = "tasty_bytes_dbt_db"
  comment                     = "This is database for dbt project"
  data_retention_time_in_days = 1
}




# 1. Read and parse the CSV file into a map, keyed by the login_name
locals {
  schemas_data = csvdecode(file("${path.module}/csv/dbt_project_schemas.csv"))
}

# csvdecode(...): Takes that raw text and converts it into a list of maps, where each row becomes a dictionary 
# for example: 
# [ 
#     {first_name = "John", last_name = "Doe" ...}, 
 #    {...} 
# ]



# 2. Create the schemas dynamically using for_each
resource "snowflake_schema" "bulk_schemas" {
  # provider = snowflake.provider_with_ACCOUNTADMIN
  
  # Dynamically construct the key and login_name as FIRST_LAST
  for_each = { for schema in local.schemas_data : upper("${snowflake_database.terraform_tasty_bytes_dbt_db.name}_${schema.schema_name}") => schema }
      #      ^                                                                                                                                        ^
      #      ^                                                                                                                                        ^
      # The curly braces {} are the exact syntax in Terraform that tell it: "Take the results of this loop and build a Map (an object/dictionary)."
      # each.key evaluates to "JOHN_DOE", "JANE_SMITH", etc.

        name                = each.value.schema_name
        database            = snowflake_database.terraform_tasty_bytes_dbt_db.name
        with_managed_access = true
        is_transient        = true
        comment             = each.value.comment

}