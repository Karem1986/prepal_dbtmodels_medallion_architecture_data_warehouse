-- 1. SCHEMAS INITIALIZATION

CREATE SCHEMA IF NOT EXISTS bronze_sap;
CREATE SCHEMA IF NOT EXISTS bronze_onprem;
CREATE SCHEMA IF NOT EXISTS audit;

-- 2. TABLES (RAW INGESTION & SIMPLE LOGS)

-- SAP Ingestion
CREATE TABLE IF NOT EXISTS bronze_sap.sap_sales_orders (
    sap_order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_date TIMESTAMP,
    net_value NUMERIC(18, 2),
    currency VARCHAR(10),
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Raw On-Premises Ingestion (Legacy Retail System with Pricing)
CREATE TABLE IF NOT EXISTS bronze_onprem.retail_transactions (
    txn_id VARCHAR(50),
    store_id VARCHAR(50),
    product_id VARCHAR(50),
    quantity INT,
    unit_price NUMERIC(18, 2),
    txn_timestamp TIMESTAMP,
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Simple log table to show manual tracking in the demo
CREATE TABLE IF NOT EXISTS audit.migration_logs (
    log_id SERIAL PRIMARY KEY,
    procedure_name VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL,
    records_processed INT DEFAULT 0,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. STORED PROCEDURES: EXTRACT & LOAD

-- PROCEDURE 1: Extract data from SAP ERP
CREATE OR REPLACE PROCEDURE bronze_sap.usp_extract_sap_orders()
LANGUAGE plpgsql AS $$
BEGIN
    -- Clear old data to simulate a fresh batch extract
    TRUNCATE TABLE bronze_sap.sap_sales_orders;

    -- Insert Dummy SAP Sales Orders
    INSERT INTO bronze_sap.sap_sales_orders (sap_order_id, customer_id, order_date, net_value, currency)
    VALUES 
        ('SO-1001', 'CUST_A', '2026-07-15 10:00:00', 1500.00, 'EUR'),
        ('SO-1002', 'CUST_B', '2026-07-15 11:30:00', 450.50, 'EUR'),
        ('SO-1003', 'CUST_C', '2026-07-15 14:15:00', 2200.00, 'EUR');

    -- Manually log the success inside the procedure
    INSERT INTO audit.migration_logs (procedure_name, status, records_processed)
    VALUES ('usp_extract_sap_orders', 'SUCCESS', 3);
END;
$$;


-- PROCEDURE 2: Load price data onto our on-premises DWH
CREATE OR REPLACE PROCEDURE bronze_onprem.usp_sync_retail_transactions()
LANGUAGE plpgsql AS $$
BEGIN
    -- Clear old data to simulate a fresh load
    TRUNCATE TABLE bronze_onprem.retail_transactions;

    -- Insert legacy transactional pricing data
    INSERT INTO bronze_onprem.retail_transactions (txn_id, store_id, product_id, quantity, unit_price, txn_timestamp)
    VALUES 
        ('TXN-5001', 'STORE_01', 'PROD_99', 5, 20.00, '2026-07-15 09:00:00'),
        ('TXN-5002', 'STORE_02', 'PROD_102', 2, 45.00, '2026-07-15 12:15:00'),
        ('TXN-5003', 'STORE_01', 'PROD_05', 10, 12.50, '2026-07-15 15:30:00');

    -- Manually log the success inside the procedure
    INSERT INTO audit.migration_logs (procedure_name, status, records_processed)
    VALUES ('usp_sync_retail_transactions', 'SUCCESS', 3);
END;
$$;