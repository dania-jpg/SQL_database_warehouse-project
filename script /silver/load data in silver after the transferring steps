/*
===============================================================================
ETL Script: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This script performs ETL transformations to clean, standardize, and deduplicate 
    raw data from the 'bronze' schema and load it into the 'silver' schema.

Transformations Included:
    - Deduplication using Window Functions (ROW_NUMBER)
    - Text standardization (TRIM, UPPER, Case statements)
    - Date parsing (Converting INT/VARCHAR to DATE)
    - Data quality corrections (Fixing invalid sales/prices, filtering future dates)
===============================================================================
*/
-- Run this EXEC statement separately to test the procedure AFTER you create it
-- EXEC silver.load_data;
-- GO

CREATE OR ALTER PROCEDURE silver.load_data AS
BEGIN
    -- Declare variables for performance profiling metrics
    DECLARE @start_time DATETIME, @end_time DATETIME;
    DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME; 

    BEGIN TRY
        PRINT '============================================================';
        PRINT 'STARTING SILVER LAYER LOADING PROCESS';
        PRINT '============================================================';
        
        -- Start full batch timer
        SET @batch_start_time = GETDATE();

        -- ============================================================================
        -- 1. Load CRM Tables
        -- ============================================================================
        PRINT '------------------------------------------------------------';
        PRINT 'PROCESSING CRM TABLES';
        PRINT '------------------------------------------------------------';

        -- Processing: silver.crm_cust_info
        SET @start_time = GETDATE();
        PRINT 'Truncating table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT 'Loading table: silver.crm_cust_info...';
        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_gndr,
            cst_marital_status,
            cst_create_date
        )
        SELECT 
            cst_id,
            cst_key,
            TRIM(cst_firstname), 
            TRIM(cst_lastname),  
            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single' 
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END AS cst_marital_status, 
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr,
            cst_create_date  
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last 
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag_last = 1;
        
        SET @end_time = GETDATE();
        PRINT '>> SUCCESS: silver.crm_cust_info loaded.';
        PRINT '>> Step Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '------------------------------------------------------------';


        -- Processing: silver.crm_prd_info
        SET @start_time = GETDATE();
        PRINT 'Truncating table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT 'Loading table: silver.crm_prd_info...';
        INSERT INTO silver.crm_prd_info (
            prd_id,              
            cat_id,             
            prd_key,             
            prd_nm,              
            prd_cost,           
            prd_line,            
            prd_start_dt,       
            prd_end_dt
        )
        SELECT 
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            REPLACE(SUBSTRING(prd_key, 7, LEN(prd_key)), '-', '_') AS prd_key,
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost, 
            CASE 
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,
            CAST(prd_start_dt AS DATE) AS prd_start_dt,
            CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
        FROM bronze.crm_prd_info;
        
        SET @end_time = GETDATE();
        PRINT '>> SUCCESS: silver.crm_prd_info loaded.';
        PRINT '>> Step Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '------------------------------------------------------------';


        -- Processing: silver.crm_sales_details
        SET @start_time = GETDATE();
        PRINT 'Truncating table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT 'Loading table: silver.crm_sales_details...';
        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT 
            sls_ord_num,
            REPLACE(sls_prd_key, '-', '_') AS sls_prd_key, 
            sls_cust_id,
            CASE 
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
            END AS sls_order_dt,
            CASE 
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
            END AS sls_ship_dt,
            CASE 
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) 
            END AS sls_due_dt,
            CASE
                WHEN sls_sales != sls_quantity * ABS(sls_price) OR sls_sales IS NULL OR sls_sales <= 0 
                    THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales 
            END AS sls_sales,
            sls_quantity,
            CASE
                WHEN sls_price IS NULL OR sls_price <= 0 
                    THEN NULLIF(sls_sales, 0) / sls_quantity
                ELSE sls_price
            END AS sls_price
        FROM bronze.crm_sales_details;
        
        SET @end_time = GETDATE();
        PRINT '>> SUCCESS: silver.crm_sales_details loaded.';
        PRINT '>> Step Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';


        -- ============================================================================
        -- 2. Load ERP Tables
        -- ============================================================================
        PRINT '------------------------------------------------------------';
        PRINT 'PROCESSING ERP TABLES';
        PRINT '------------------------------------------------------------';

        -- Processing: silver.erp_CUST_AZ12
        SET @start_time = GETDATE();
        PRINT 'Truncating table: silver.erp_CUST_AZ12';
        TRUNCATE TABLE silver.erp_CUST_AZ12;

        PRINT 'Loading table: silver.erp_CUST_AZ12...';
        INSERT INTO silver.erp_CUST_AZ12 (
            cid,
            bdate,
            gen
        )
        SELECT 
            CASE
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END AS cid,
            CASE
                WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END AS bdate,
            CASE 
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'n/a'
            END AS gen
        FROM bronze.erp_CUST_AZ12;
        
        SET @end_time = GETDATE();
        PRINT '>> SUCCESS: silver.erp_CUST_AZ12 loaded.';
        PRINT '>> Step Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '------------------------------------------------------------';


        -- Processing: silver.erp_LOC_A101
        SET @start_time = GETDATE();
        PRINT 'Truncating table: silver.erp_LOC_A101';
        TRUNCATE TABLE silver.erp_LOC_A101;

        PRINT 'Loading table: silver.erp_LOC_A101...';
        INSERT INTO silver.erp_LOC_A101 (
            cid,
            cntry
        )
        SELECT 
            REPLACE(cid, '-', '') AS cid, 
            CASE 
                WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'n/a'
                ELSE TRIM(cntry)
            END AS cntry
        FROM bronze.erp_LOC_A101;
        
        SET @end_time = GETDATE();
        PRINT '>> SUCCESS: silver.erp_LOC_A101 loaded.';
        PRINT '>> Step Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '------------------------------------------------------------';


        -- Processing: silver.erp_PX_CAT_G1V2
        SET @start_time = GETDATE();
        PRINT 'Truncating table: silver.erp_PX_CAT_G1V2';
        TRUNCATE TABLE silver.erp_PX_CAT_G1V2;

        PRINT 'Loading table: silver.erp_PX_CAT_G1V2...';
        INSERT INTO silver.erp_PX_CAT_G1V2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT 
            id,
            cat,
            subcat,
            maintenance
        FROM bronze.erp_PX_CAT_G1V2;
        
        SET @end_time = GETDATE();
        PRINT '>> SUCCESS: silver.erp_PX_CAT_G1V2 loaded.';
        PRINT '>> Step Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        
        -- End full batch timer
        SET @batch_end_time = GETDATE();

        PRINT '============================================================';
        PRINT 'SILVER LAYER LOADING COMPLETE';
        PRINT 'Total Batch Load Time: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '============================================================';

    END TRY
    BEGIN CATCH
        -- Capture, log, and identify system-level exceptions safely
        PRINT '============================================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State:   ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '============================================================';
    END CATCH
END;
GO
