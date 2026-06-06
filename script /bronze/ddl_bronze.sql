/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates the raw data tables in the 'bronze' schema, dropping 
    existing tables if they already exist.
    Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

-- ============================================================================
-- CRM Source Tables
-- ============================================================================

PRINT 'Creating Table: bronze.crm_cust_info';
DROP TABLE IF EXISTS bronze.crm_cust_info;
GO
CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE
);
GO

PRINT 'Creating Table: bronze.crm_prd_info';
DROP TABLE IF EXISTS bronze.crm_prd_info;
GO
CREATE TABLE bronze.crm_prd_info (
    prd_id              INT,
    prd_key             NVARCHAR(50),
    prd_nm              NVARCHAR(50),
    prd_cost            INT,
    prd_line            NVARCHAR(50),
    prd_start_dt        DATETIME,
    prd_end_dt          DATETIME
);
GO

PRINT 'Creating Table: bronze.crm_sales_details';
DROP TABLE IF EXISTS bronze.crm_sales_details;
GO
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num         NVARCHAR(50),
    sls_prd_key         NVARCHAR(50),
    sls_cust_id         INT,
    sls_order_dt        INT,
    sls_ship_dt         INT,
    sls_due_dt          INT,
    sls_sales           INT,
    sls_quantity        INT,
    sls_price           INT
);
GO

-- ============================================================================
-- ERP Source Tables
-- ============================================================================

PRINT 'Creating Table: bronze.erp_CUST_AZ12';
DROP TABLE IF EXISTS bronze.erp_CUST_AZ12;
GO
CREATE TABLE bronze.erp_CUST_AZ12 (
    CID                 NVARCHAR(50),
    BDATE               DATE,
    GEN                 NVARCHAR(50)
);
GO

PRINT 'Creating Table: bronze.erp_LOC_A101';
DROP TABLE IF EXISTS bronze.erp_LOC_A101;
GO
CREATE TABLE bronze.erp_LOC_A101 (
    CID                 NVARCHAR(50),
    CNTRY               NVARCHAR(50)
);
GO

PRINT 'Creating Table: bronze.erp_PX_CAT_G1V2';
DROP TABLE IF EXISTS bronze.erp_PX_CAT_G1V2;
GO
CREATE TABLE bronze.erp_PX_CAT_G1V2 (
    ID                  NVARCHAR(50),
    CAT                 NVARCHAR(50),
    SUBCAT              NVARCHAR(50),
    MAINTENANCE         NVARCHAR(50)
);
GO
