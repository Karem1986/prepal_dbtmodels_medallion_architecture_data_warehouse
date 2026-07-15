-- ============================================================================
-- 1. INSERT MOCK DATA INTO BRONZE INGESTION TABLES
-- ============================================================================
INSERT INTO bronze_sap.sap_sales_orders (sap_order_id, customer_id, order_date, net_value, currency)
VALUES 
    ('SO-1001', 'CUST_A', '2026-07-15 10:00:00', 1500.00, 'EUR'),
    ('SO-1002', 'CUST_B', '2026-07-15 11:30:00', 450.50, 'EUR');

INSERT INTO bronze_onprem.retail_transactions (txn_id, store_id, product_id, quantity, unit_price, txn_timestamp)
VALUES 
    ('TXN-5001', 'STORE_01', 'PROD_99', 5, 20.00, '2026-07-15 09:00:00'),
    ('TXN-5002', 'STORE_02', 'PROD_102', 2, 45.00, '2026-07-15 12:15:00');

-- ============================================================================
-- 2. RUN AND AUDIT THE STORED PROCEDURES
-- ============================================================================

-- Step A: Start & log the migration process using a transaction block
DO $$
DECLARE
    v_log_id INT;
BEGIN
    -- Call the audit startup procedure
    CALL audit.sp_log_migration_start('mock_extraction_pipeline', v_log_id);
    
    -- Print out the generated ID for visibility
    RAISE NOTICE 'Migration started. Assigned Log ID: %', v_log_id;
    
    -- Step B: Simulate work by updating the logs with success
    -- (In real life, your ETL process runs here)
    CALL audit.sp_log_migration_success(v_log_id, 4); -- 4 total records ingested
    
    RAISE NOTICE 'Migration successfully completed for Log ID: %', v_log_id;
END;
$$;

-- ============================================================================
-- 3. VERIFY INGESTION AND METRICS
-- ============================================================================
SELECT * FROM audit.migration_logs;