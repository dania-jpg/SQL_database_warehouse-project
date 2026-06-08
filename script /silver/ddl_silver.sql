/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates the cleansed and standardized tables in the 'silver' schema.
    It drops existing tables if they already exist.
    It also includes a 'dwh_create_date' audit column to track when data 
    was loaded into the Silver layer.
===============================================================================
*/

-- ============================================================================
-- CRM Tables (Cleansed)
-- ============================================================================

PRINT 'Creating Table: silver.crm_cust_info';
DROP TABLE IF EXISTS silver.crm_cust_info;
GO
CREATE TABLE silver.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE,
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);
GO

PRINT 'Creating Table: silver.crm_prd_info';
DROP TABLE IF EXISTS silver.crm_prd_info;
GO
CREATE TABLE silver.crm_prd_info (
    prd_id              INT,
    prd_key             NVARCHAR(50),
    prd_nm              NVARCHAR(50),
    prd_cost            INT,
    prd_line            NVARCHAR(50),
    prd_start_dt        DATE, -- Converted from DATETIME to DATE
    prd_end_dt          DATE, -- Converted from DATETIME to DATE
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);
GO

PRINT 'Creating Table: silver.crm_sales_details';
DROP TABLE IF EXISTS silver.crm_sales_details;
GO
CREATE TABLE silver.crm_sales_details (
    sls_ord_num         NVARCHAR(50),
    sls_prd_key         NVARCHAR(50),
    sls_cust_id         INT,
    sls_order_dt        DATE, -- Standardized from INT to DATE
    sls_ship_dt         DATE, -- Standardized from INT to DATE
    sls_due_dt          DATE, -- Standardized from INT to DATE
    sls_sales           INT,
    sls_quantity        INT,
    sls_price           INT,
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);
GO

-- ============================================================================
-- ERP Tables (Cleansed)
-- ============================================================================

PRINT 'Creating Table: silver.erp_CUST_AZ12';
DROP TABLE IF EXISTS silver.erp_CUST_AZ12;
GO
CREATE TABLE silver.erp_CUST_AZ12 (
    CID                 NVARCHAR(50),
    BDATE               DATE,
    GEN                 NVARCHAR(50),
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);
GO

PRINT 'Creating Table: silver.erp_LOC_A101';
DROP TABLE IF EXISTS silver.erp_LOC_A101;
GO
CREATE TABLE silver.erp_LOC_A101 (
    CID                 NVARCHAR(50),
    CNTRY               NVARCHAR(50),
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);
GO

PRINT 'Creating Table: silver.erp_PX_CAT_G1V2';
DROP TABLE IF EXISTS silver.erp_PX_CAT_G1V2;
GO
CREATE TABLE silver.erp_PX_CAT_G1V2 (
    ID                  NVARCHAR(50),
    CAT                 NVARCHAR(50),
    SUBCAT              NVARCHAR(50),
    MAINTENANCE         NVARCHAR(50),
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);
GO
