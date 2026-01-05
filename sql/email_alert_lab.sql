
/*==========================================================
 Project:   Snowflake Email Notification Lab
 File:      email_alert_lab.sql
 Author :   Malaya Kumar Padhi
 LinkedIn:  https://www.linkedin.com/in/mkpadhi/
 Purpose:   Demonstrate email notifications using Alerts
==========================================================*/


-- PREREQUISITES:
-- 1. Appropriate role with privileges to create notification integrations and alerts
-- 2. A running virtual warehouse (e.g., COMPUTE_WH)
-- 3. Valid email address to be whitelisted

-- =====================================================
-- STEP 1: Create Notification Integration (EMAIL)
-- One-time admin setup
-- =====================================================

CREATE OR REPLACE NOTIFICATION INTEGRATION email_int_lab
  TYPE = EMAIL
  ENABLED = TRUE
  ALLOWED_RECIPIENTS = ('mkpadhi@gmail.com');

-- NOTE:
-- - Notification Integration is mandatory
-- - Only whitelisted recipients can receive emails

-- =====================================================
-- STEP 2: Create Database, Schema, and Test Table
-- =====================================================

CREATE OR REPLACE DATABASE lab_db;
CREATE OR REPLACE SCHEMA lab_db.public;

CREATE OR REPLACE TABLE lab_db.public.order_data (
    order_id NUMBER,
    order_date DATE
);

-- The table is intentionally left EMPTY
-- This will trigger the alert condition

-- =====================================================
-- STEP 3: Create Alert
-- =====================================================


CREATE OR REPLACE ALERT zero_row_alert
  WAREHOUSE = COMPUTE_WH
  SCHEDULE = '2 MINUTE'
IF
  ( EXISTS
    (
      SELECT 1
WHERE NOT EXISTS (
    SELECT 1
    FROM lab_db.public.order_data
                )
    )
)
THEN
  CALL SYSTEM$SEND_EMAIL(
    'email_int_lab',
    'mkpadhi@gmail.com',
    'Snowflake Alert: No Data Detected',
    'The ORDER_DATA table currently contains zero records. Thanks, Malay'
  );

-- =====================================================
-- STEP 4: Enable (Resume) the Alert
-- Alerts are created in SUSPENDED state by default
-- =====================================================

ALTER ALERT zero_row_alert RESUME;

-- =====================================================
-- STEP 5: Validate Alert Status
-- =====================================================

SHOW ALERTS;


-- CHECKING ALERT  EXECUTION STATUS

SELECT *
FROM TABLE(
  INFORMATION_SCHEMA.ALERT_HISTORY(
    ALERT_NAME => 'ZERO_ROW_ALERT'
  )
)
ORDER BY SCHEDULED_TIME DESC;


ALTER ALERT zero_row_alert SUSPEND;
-- =====================================================
-- STEP 6: Optional Cleanup (Run when finished testing)
-- =====================================================

-- ALTER ALERT zero_row_alert SUSPEND;
-- DROP ALERT zero_row_alert;
-- DROP TABLE lab_db.public.order_data;
-- DROP DATABASE lab_db;
-- DROP NOTIFICATION INTEGRATION email_int_lab; -- optional (admin decision)

-- =====================================================
-- END OF FILE
-- =====================================================
