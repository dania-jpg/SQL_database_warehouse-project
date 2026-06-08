/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads raw, unprocessed data as-is from source 
    systems (CRM and ERP) into the 'Bronze' layer of the data warehouse.
    
    The objective of this layer is to 
    provide a historical archive of source data for traceability and debugging.

Usage:
    EXEC bronze.load_data;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_data AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME; 

    BEGIN TRY
        PRINT '==============================================';
        PRINT 'Loading Bronze Layer';
        PRINT '==============================================';
        
        -- Start full batch timer
        SET @batch_start_time = GETDATE();

        PRINT 'Loading CRM tables';
        PRINT '----------------------------------------------';
        
        -- 1. Load crm_cust_info
        SET @start_time = GETDATE();
        PRINT 'Truncating table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT 'Loading table: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\path_to_file\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- 2. Load crm_prd_info
        SET @start_time = GETDATE();
        PRINT 'Truncating table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT 'Loading table: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\path_to_file\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- 3. Load crm_sales_details
        SET @start_time = GETDATE();
        PRINT 'Truncating table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT 'Loading table: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\path_to_file\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        PRINT 'Loading ERP tables';
        PRINT '----------------------------------------------';

        -- 4. Load erp_CUST_AZ12
        SET @start_time = GETDATE();
        PRINT 'Truncating table: bronze.erp_CUST_AZ12';
        TRUNCATE TABLE bronze.erp_CUST_AZ12;

        PRINT 'Loading table: bronze.erp_CUST_AZ12';
        BULK INSERT bronze.erp_CUST_AZ12
        FROM 'C:\path_to_file\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- 5. Load erp_LOC_A101
        SET @start_time = GETDATE();
        PRINT 'Truncating table: bronze.erp_LOC_A101';
        TRUNCATE TABLE bronze.erp_LOC_A101;

        PRINT 'Loading table: bronze.erp_LOC_A101';
        BULK INSERT bronze.erp_LOC_A101
        FROM 'C:\path_to_file\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- 6. Load erp_PX_CAT_G1V2
        SET @start_time = GETDATE();
        PRINT 'Truncating table: bronze.erp_PX_CAT_G1V2';
        TRUNCATE TABLE bronze.erp_PX_CAT_G1V2;

        PRINT 'Loading table: bronze.erp_PX_CAT_G1V2';
        BULK INSERT bronze.erp_PX_CAT_G1V2
        FROM 'C:\path_to_file\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- End full batch timer
        SET @batch_end_time = GETDATE();
        
        PRINT '==============================================';
        PRINT 'Data load completed successfully';
        PRINT 'Total Batch Load Time: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==============================================';

    END TRY
    BEGIN CATCH
        PRINT '==============================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State:   ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==============================================';
    END CATCH
END;
GO
