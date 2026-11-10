
resource "snowflake_email_notification_integration" "NOTIFICATION_TO_VAAAAA_J_OUTLOOK" {
  provider = snowflake.provider_with_ACCOUNTADMIN # <--- Telling it to use the alias
  name    = "NOTIFICATION_TO_VAAAAA_J_OUTLOOK"
  comment = "A notification integration."

  enabled            = true
  allowed_recipients = [var.notification_email_for_operators]
}


resource "snowflake_alert" "ALERT_TO_VAAAA_J_OUTLOOK" {
  name      = "ALERT_TO_VAAAA_J_OUTLOOK"
  provider     = snowflake.provider_with_ACCOUNTADMIN # <--- Telling it to use the alias
  database  = snowflake_database.terraform_util_db.name
  schema    = snowflake_schema.util_schema.name
  warehouse = snowflake_warehouse.tf_udemy_wh.name

# run it every hour but only from 7am to 10pm EST  
  alert_schedule {
    cron {
      expression = "0 7-22 * * *"
      time_zone  = "America/New_York"
    }
  }

# each run only looks at the last 60 minutes
  condition = <<-EOT
    SELECT 1
    FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY_BY_WAREHOUSE(
         WAREHOUSE_NAME => 'COMPUTE_WH',
         END_TIME_RANGE_START => DATEADD('minute', -60, CURRENT_TIMESTAMP())))
    WHERE execution_status IN ('QUEUED', 'QUEUED_REPAIRING_WAREHOUSE', 'BLOCKED')
       OR queued_overload_time > 30000
  EOT

  action = <<-EOT
    CALL SYSTEM$SEND_EMAIL(
      '${snowflake_email_notification_integration.NOTIFICATION_TO_VAAAAA_J_OUTLOOK.name}',
      '${var.notification_email_for_operators}',
      'Snowflake: queued queries on COMPUTE_WH',
      'Queries are queuing on COMPUTE_WH. Check Query History or warehouse load.'
    )
  EOT

  enabled = true
  comment = "my alert"
}
