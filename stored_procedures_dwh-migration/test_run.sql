-- 1. RUN THE STORED PROCEDURES

SELECT 'Executing SAP Extraction...' AS status;
CALL bronze_sap.usp_extract_sap_orders();

SELECT 'Executing On-Premise Extraction...' AS status;
CALL bronze_onprem.usp_sync_retail_transactions();

-- 2. VERIFY THE INGESTED DATA and CHECK LOGS

-- Check the Audit Logs
SELECT log_id, procedure_name, status, records_processed, completed_at 
FROM audit.migration_logs;

-- Verify SAP Data loaded
SELECT * FROM bronze_sap.sap_sales_orders;

-- Verify Retail Price Data loaded
SELECT * FROM bronze_onprem.retail_transactions;