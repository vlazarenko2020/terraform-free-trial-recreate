# terraform {
#   required_providers {
#     snowflake = {
#       source  = "Snowflake-Labs/snowflake"
#       version = "~> 1.0"
#     }
#   }
# }

# # Auth via env vars / ~/.snowflake/config (SNOWFLAKE_ORGANIZATION_NAME, SNOWFLAKE_ACCOUNT_NAME, SNOWFLAKE_USER, ...)
# provider "snowflake" {
#   role = var.role
# }

variable "role" {
  type    = string
  default = "SYSADMIN"
}

variable "database_name" {
  type    = string
  default = "FROSTBYTE_TASTY_BYTES_2"
}

# ---------------------------------------------------------------------------
# Database & schemas (PUBLIC is created automatically with the database)
# ---------------------------------------------------------------------------
resource "snowflake_database" "FROSTBYTE_TASTY_BYTES" {
  name = var.database_name
}

resource "snowflake_schema" "raw_pos" {
  database = snowflake_database.FROSTBYTE_TASTY_BYTES.name
  name     = "RAW_POS"
}

resource "snowflake_schema" "raw_customer" {
  database = snowflake_database.FROSTBYTE_TASTY_BYTES.name
  name     = "RAW_CUSTOMER"
}

# ---------------------------------------------------------------------------
# Stage
# ---------------------------------------------------------------------------
resource "snowflake_stage_external_s3" "s3_tastybytes" {
  database = snowflake_database.FROSTBYTE_TASTY_BYTES.name
  schema   = snowflake_schema.raw_pos.name
  name     = "S3_TASTYBYTES"
  url      = "s3://sfquickstarts/tastybytes/"
}
# ---------------------------------------------------------------------------
# Tables
# ---------------------------------------------------------------------------
locals {
  tables = {
    CUSTOMER_LOYALTY = {
      schema = "RAW_CUSTOMER"
      columns = [
        ["CUSTOMER_ID", "NUMBER(38,0)"],
        ["FIRST_NAME", "VARCHAR"],
        ["LAST_NAME", "VARCHAR"],
        ["CITY", "VARCHAR"],
        ["COUNTRY", "VARCHAR"],
        ["POSTAL_CODE", "VARCHAR"],
        ["PREFERRED_LANGUAGE", "VARCHAR"],
        ["GENDER", "VARCHAR"],
        ["FAVOURITE_BRAND", "VARCHAR"],
        ["MARITAL_STATUS", "VARCHAR"],
        ["CHILDREN_COUNT", "VARCHAR"],
        ["SIGN_UP_DATE", "DATE"],
        ["BIRTHDAY", "DATE"],
        ["E_MAIL", "VARCHAR"],
        ["PHONE_NUMBER", "VARCHAR"],
      ]
    }
    COUNTRY = {
      schema = "RAW_POS"
      columns = [
        ["COUNTRY_ID", "NUMBER(38,0)"],
        ["COUNTRY", "VARCHAR"],
        ["ISO_CURRENCY", "VARCHAR"],
        ["ISO_COUNTRY", "VARCHAR"],
        ["CITY_ID", "NUMBER(38,0)"],
        ["CITY", "VARCHAR"],
        ["CITY_POPULATION", "NUMBER(38,0)"],
      ]
    }
    FRANCHISE = {
      schema = "RAW_POS"
      columns = [
        ["FRANCHISE_ID", "NUMBER(38,0)"],
        ["FIRST_NAME", "VARCHAR"],
        ["LAST_NAME", "VARCHAR"],
        ["CITY", "VARCHAR"],
        ["COUNTRY", "VARCHAR"],
        ["E_MAIL", "VARCHAR"],
        ["PHONE_NUMBER", "VARCHAR"],
      ]
    }
    LOCATION = {
      schema = "RAW_POS"
      columns = [
        ["LOCATION_ID", "NUMBER(38,0)"],
        ["PLACEKEY", "VARCHAR"],
        ["LOCATION", "VARCHAR"],
        ["CITY", "VARCHAR"],
        ["REGION", "VARCHAR"],
        ["ISO_COUNTRY_CODE", "VARCHAR"],
        ["COUNTRY", "VARCHAR"],
      ]
    }
    MENU = {
      schema = "RAW_POS"
      columns = [
        ["MENU_ID", "NUMBER(19,0)"],
        ["MENU_TYPE_ID", "NUMBER(38,0)"],
        ["MENU_TYPE", "VARCHAR"],
        ["TRUCK_BRAND_NAME", "VARCHAR"],
        ["MENU_ITEM_ID", "NUMBER(38,0)"],
        ["MENU_ITEM_NAME", "VARCHAR"],
        ["ITEM_CATEGORY", "VARCHAR"],
        ["ITEM_SUBCATEGORY", "VARCHAR"],
        ["COST_OF_GOODS_USD", "NUMBER(38,4)"],
        ["SALE_PRICE_USD", "NUMBER(38,4)"],
        ["MENU_ITEM_HEALTH_METRICS_OBJ", "VARIANT"],
      ]
    }
    ORDER_DETAIL = {
      schema = "RAW_POS"
      columns = [
        ["ORDER_DETAIL_ID", "NUMBER(38,0)"],
        ["ORDER_ID", "NUMBER(38,0)"],
        ["MENU_ITEM_ID", "NUMBER(38,0)"],
        ["DISCOUNT_ID", "VARCHAR"],
        ["LINE_NUMBER", "NUMBER(38,0)"],
        ["QUANTITY", "NUMBER(38,0)"],
        ["UNIT_PRICE", "NUMBER(38,4)"],
        ["PRICE", "NUMBER(38,4)"],
        ["ORDER_ITEM_DISCOUNT_AMOUNT", "VARCHAR"],
      ]
    }
    ORDER_HEADER = {
      schema = "RAW_POS"
      columns = [
        ["ORDER_ID", "NUMBER(38,0)"],
        ["TRUCK_ID", "NUMBER(38,0)"],
        ["LOCATION_ID", "NUMBER(38,0)"],
        ["CUSTOMER_ID", "NUMBER(38,0)"],
        ["DISCOUNT_ID", "VARCHAR"],
        ["SHIFT_ID", "NUMBER(38,0)"],
        ["SHIFT_START_TIME", "TIME"],
        ["SHIFT_END_TIME", "TIME"],
        ["ORDER_CHANNEL", "VARCHAR"],
        ["ORDER_TS", "TIMESTAMP_NTZ"],
        ["SERVED_TS", "VARCHAR"],
        ["ORDER_CURRENCY", "VARCHAR"],
        ["ORDER_AMOUNT", "NUMBER(38,4)"],
        ["ORDER_TAX_AMOUNT", "VARCHAR"],
        ["ORDER_DISCOUNT_AMOUNT", "VARCHAR"],
        ["ORDER_TOTAL", "NUMBER(38,4)"],
      ]
    }
    TRUCK = {
      schema = "RAW_POS"
      columns = [
        ["TRUCK_ID", "NUMBER(38,0)"],
        ["FRANCHISE_ID", "NUMBER(38,0)"],
        ["PRIMARY_CITY", "VARCHAR"],
        ["REGION", "VARCHAR"],
        ["ISO_REGION", "VARCHAR"],
        ["COUNTRY", "VARCHAR"],
        ["ISO_COUNTRY_CODE", "VARCHAR"],
        ["FRANCHISE_FLAG", "NUMBER(38,0)"],
        ["YEAR", "NUMBER(38,0)"],
        ["MAKE", "VARCHAR"],
        ["MODEL", "VARCHAR"],
        ["EV_FLAG", "NUMBER(38,0)"],
        ["TRUCK_OPENING_DATE", "NUMBER(38,0)"],
        ["TRUCK_START_DATE", "DATE"],
      ]
    }
  }

  schemas = {
    RAW_POS      = snowflake_schema.raw_pos.name
    RAW_CUSTOMER = snowflake_schema.raw_customer.name
  }
}

resource "snowflake_table" "tables" {
  for_each = local.tables

  database = snowflake_database.FROSTBYTE_TASTY_BYTES.name
  schema   = local.schemas[each.value.schema]
  name     = each.key

  dynamic "column" {
    for_each = each.value.columns
    content {
      name     = column.value[0]
      type     = column.value[1]
      nullable = true
    }
  }
}
