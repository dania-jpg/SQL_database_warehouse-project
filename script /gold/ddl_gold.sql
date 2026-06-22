/*
===============================================================================
DDL Script: Create Gold Views (Presentation Layer)
===============================================================================
Script Purpose:
    This script defines the 'gold' schema views, which represent the final 
    Presentation Layer of the Data Warehouse (Star Schema dimensional model).

Design Specifications:
    - Business-Ready: Column names are aliased to clean, user-friendly language.
    - Idempotent Deployment: Uses 'CREATE OR ALTER' to ensure the script can be 
      re-run safely without object-existence errors or loss of permissions.
    - Order of Execution: Dimensions are built first, followed by Fact views 
      to respect object dependency integrity.
===============================================================================
*/

-- ============================================================================
-- 1. CREATE VIEW: gold.dim_customer
-- ============================================================================
PRINT 'Creating or Altering View: gold.dim_customer';
GO

CREATE OR ALTER VIEW gold.dim_customer AS
SELECT 
    ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id                            AS customer_id,
    ci.cst_key                           AS customer_number,
    ci.cst_firstname                     AS first_name,
    ci.cst_lastname                      AS last_name,
    cc.CNTRY                             AS country,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END                                  AS gender,
    ci.cst_marital_status                AS marital_status,
    ca.bdate                             AS birthdate,
    ci.cst_create_date                   AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_CUST_AZ12 ca 
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_LOC_A101 cc 
    ON ci.cst_key = cc.cid;
GO

-- ============================================================================
-- 2. CREATE VIEW: gold.dim_product
-- ============================================================================
PRINT 'Creating or Altering View: gold.dim_product';
GO

CREATE OR ALTER VIEW gold.dim_product AS
SELECT 
    ROW_NUMBER() OVER(ORDER BY pa.prd_start_dt, pa.prd_key) AS product_key,
    pa.prd_id                                              AS product_id,
    pa.prd_key                                             AS product_number,
    pa.prd_nm                                              AS product_name,
    pa.cat_id                                              AS category_id,
    pe.CAT                                                 AS category,
    pe.SUBCAT                                              AS subcategory,
    pe.MAINTENANCE                                         AS maintenance,
    pa.prd_cost                                            AS cost,
    pa.prd_line                                            AS product_line,
    pa.prd_start_dt                                        AS start_date
FROM silver.crm_prd_info pa
LEFT JOIN silver.erp_PX_CAT_G1V2 pe 
    ON pa.cat_id = pe.ID
WHERE pa.prd_end_dt IS NULL; -- Filters for only active product allocations
GO

-- ============================================================================
-- 3. CREATE VIEW: gold.fast_sales (Fact Layer)
-- ============================================================================
PRINT 'Creating or Altering View: gold.fast_sales';
GO

CREATE OR ALTER VIEW gold.fast_sales AS
SELECT 
    fa.sls_ord_num AS order_number,
    pr.product_key AS product_key,
    cs.customer_key AS customer_key,
    fa.sls_order_dt AS order_date,
    fa.sls_ship_dt  AS ship_date,
    fa.sls_due_dt   AS due_date,
    fa.sls_sales    AS sales,
    fa.sls_quantity AS quantity,
    fa.sls_price    AS price
FROM silver.crm_sales_details fa
LEFT JOIN gold.dim_customer cs 
    ON fa.sls_cust_id = cs.customer_id
LEFT JOIN gold.dim_product pr 
    ON fa.sls_prd_key = pr.product_number;
GO

PRINT '============================================================';
PRINT 'GOLD LAYER VIEWS DEPLOYED SUCCESSFULLY';
PRINT '============================================================';
