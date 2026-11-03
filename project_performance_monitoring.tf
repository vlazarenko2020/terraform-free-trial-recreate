
resource "snowflake_email_notification_integration" "email_vaaaa_j_outlook" {
  provider     = snowflake.provider_with_ACCOUNTADMIN # <--- Telling it to use the alias
  name    = "notification to Vaaaaa_J_outlook"
  comment = "A notification integration."

  enabled            = true
  allowed_recipients = [var.notification_email_for_operators]
}


resource "snowflake_alert" "alert_to_vaaaa_j_outlook" {
  provider     = snowflake.provider_with_ACCOUNTADMIN # <--- Telling it to use the alias
  database  = snowflake_database.terraform_util_db.name
  schema    = snowflake_schema.util_schema.name
  name      = "alert_to_vaaaa_j_outlook"
  warehouse = snowflake_warehouse.tf_udemy_wh.name
  
  alert_schedule {
    interval = 10
  }

  condition = <<-EOT
    SELECT 1
    FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY_BY_WAREHOUSE(
         WAREHOUSE_NAME => 'COMPUTE_WH',
         END_TIME_RANGE_START => DATEADD('minute', -5, CURRENT_TIMESTAMP())))
    WHERE execution_status IN ('QUEUED', 'QUEUED_REPAIRING_WAREHOUSE', 'BLOCKED')
       OR queued_overload_time > 30000
  EOT

  action = <<-EOT
    CALL SYSTEM$SEND_EMAIL(
      '${snowflake_email_notification_integration.email_vaaaa_j_outlook.name}',
      '${var.notification_email_for_operators}',
      'Snowflake: queued queries on COMPUTE_WH',
      'Queries are queuing on COMPUTE_WH. Check Query History or warehouse load.'
    )
  EOT

  enabled = true
  comment = "my alert"
}
