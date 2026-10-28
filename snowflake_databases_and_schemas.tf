

resource "snowflake_database" "terraform_test_db" {
  name                        = "test_db"
  comment                     = "This is our 1st test database created by Terraform"
  data_retention_time_in_days = 5
}

# resource with all fields set
resource "snowflake_schema" "terraform_test_db_bronze_schema" {
  name                = "BRONZE"
  database            = snowflake_database.terraform_test_db.fully_qualified_name
  with_managed_access = true
  is_transient        = true
  comment             = "Bronze Schema for the test database created by Terraform"

  data_retention_time_in_days     = 1
  max_data_extension_time_in_days = 20
  # external_volume                               = "<external_volume_name>"
  # catalog                                       = "<catalog_name>"
  replace_invalid_characters   = false
  default_ddl_collation        = "en_US"
  storage_serialization_policy = "COMPATIBLE"
  #  log_level                                     = "INFO"
  #  trace_level                                   = "ALWAYS"
  suspend_task_after_num_failures               = 10
  task_auto_retry_attempts                      = 10
  user_task_managed_initial_warehouse_size      = "LARGE"
  user_task_timeout_ms                          = 3600000
  user_task_minimum_trigger_interval_in_seconds = 120
  quoted_identifiers_ignore_case                = false
  enable_console_output                         = false
  pipe_execution_paused                         = false

}

