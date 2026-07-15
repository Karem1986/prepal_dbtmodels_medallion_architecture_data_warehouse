-- ============================================================================
-- 1. SCHEMAS INITIALIZATION
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS bronze_sap;
CREATE SCHEMA IF NOT EXISTS bronze_onprem;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
CREATE SCHEMA IF NOT EXISTS audit;

-- ============================================================================
-- 2. BRONZE LAYER (RAW INGESTION TABLES)
-- ============================================================================

-- Raw SAP Ingestion (ERP Data)
CREATE TABLE IF NOT EXISTS bronze_sap.sap_sales_orders (
    sap_order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_date TIMESTAMP,
    net_value NUMERIC(18, 2),
    currency VARCHAR(10),
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Raw On-Premises Ingestion (Legacy Retail System)
CREATE TABLE IF NOT EXISTS bronze_onprem.retail_transactions (
    txn_id VARCHAR(50),
    store_id VARCHAR(50),
    product_id VARCHAR(50),
    quantity INT,
    unit_price NUMERIC(18, 2),
    txn_timestamp TIMESTAMP,
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit/Logging Table for Migrations
CREATE TABLE IF NOT EXISTS audit.migration_logs (
    log_id SERIAL PRIMARY KEY,
    procedure_name VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL,       -- 'RUNNING', 'SUCCESS', 'FAILED'
    records_processed INT DEFAULT 0,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    error_message TEXT
);

-- ============================================================================
-- 3. STORED PROCEDURES (MIGRATION & ORCHESTRATION ENGINE)
-- ============================================================================

-- Procedure 1: Log Start of Migration
CREATE OR REPLACE PROCEDURE audit.sp_log_migration_start(
    IN p_procedure_name VARCHAR,
    OUT p_log_id INT
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO audit.migration_logs (procedure_name, status, started_at)
    VALUES (p_procedure_name, 'RUNNING', CURRENT_TIMESTAMP)
    RETURNING log_id INTO p_log_id;
END;
$$;


-- Procedure 2: Log Completion/Success of Migration
CREATE OR REPLACE PROCEDURE audit.sp_log_migration_success(
    IN p_log_id INT,
    IN p_records_processed INT
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE audit.migration_logs
    SET status = 'SUCCESS',
        records_processed = p_records_processed,
        completed_at = CURRENT_TIMESTAMP
    WHERE log_id = p_log_id;
END;
$$;