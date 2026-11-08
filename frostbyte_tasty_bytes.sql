

-- ================================================================
-- Step 5: Load data from S3
-- ================================================================

-- 5a. Customer Loyalty
COPY INTO FROSTBYTE_TASTY_BYTES.RAW_CUSTOMER.CUSTOMER_LOYALTY
  FROM @FROSTBYTE_TASTY_BYTES.RAW_POS.S3_TASTYBYTES/raw_customer/customer_loyalty/;

-- 5b. Country
COPY INTO FROSTBYTE_TASTY_BYTES.RAW_POS.COUNTRY
  FROM @FROSTBYTE_TASTY_BYTES.RAW_POS.S3_TASTYBYTES/raw_pos/country/;

-- 5c. Franchise
COPY INTO FROSTBYTE_TASTY_BYTES.RAW_POS.FRANCHISE
  FROM @FROSTBYTE_TASTY_BYTES.RAW_POS.S3_TASTYBYTES/raw_pos/franchise/;

-- 5d. Location
COPY INTO FROSTBYTE_TASTY_BYTES.RAW_POS.LOCATION
  FROM @FROSTBYTE_TASTY_BYTES.RAW_POS.S3_TASTYBYTES/raw_pos/location/;

-- 5e. Menu
COPY INTO FROSTBYTE_TASTY_BYTES.RAW_POS.MENU
  FROM @FROSTBYTE_TASTY_BYTES.RAW_POS.S3_TASTYBYTES/raw_pos/menu/;

-- 5f. Truck
COPY INTO FROSTBYTE_TASTY_BYTES.RAW_POS.TRUCK
  FROM @FROSTBYTE_TASTY_BYTES.RAW_POS.S3_TASTYBYTES/raw_pos/truck/;

-- 5g. Order Header (large - uses multiple files)
COPY INTO FROSTBYTE_TASTY_BYTES.RAW_POS.ORDER_HEADER
  FROM @FROSTBYTE_TASTY_BYTES.RAW_POS.S3_TASTYBYTES/raw_pos/order_header/;

-- 5h. Order Detail (large - uses multiple files)
COPY INTO FROSTBYTE_TASTY_BYTES.RAW_POS.ORDER_DETAIL
  FROM @FROSTBYTE_TASTY_BYTES.RAW_POS.S3_TASTYBYTES/raw_pos/order_detail/;

-- ================================================================
-- Step 6: Verify row counts
-- ================================================================
SELECT 'CUSTOMER_LOYALTY' AS table_name, COUNT(*) AS row_count FROM FROSTBYTE_TASTY_BYTES.RAW_CUSTOMER.CUSTOMER_LOYALTY
UNION ALL SELECT 'COUNTRY', COUNT(*) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.COUNTRY
UNION ALL SELECT 'FRANCHISE', COUNT(*) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.FRANCHISE
UNION ALL SELECT 'LOCATION', COUNT(*) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.LOCATION
UNION ALL SELECT 'MENU', COUNT(*) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU
UNION ALL SELECT 'TRUCK', COUNT(*) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.TRUCK
UNION ALL SELECT 'ORDER_HEADER', COUNT(*) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.ORDER_HEADER
UNION ALL SELECT 'ORDER_DETAIL', COUNT(*) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.ORDER_DETAIL;

-- ================================================================
-- Step 7 (optional): Scale warehouse back down after load
-- ================================================================
ALTER WAREHOUSE TASTY_BYTES_WH SET WAREHOUSE_SIZE = 'XSMALL';



