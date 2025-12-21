/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of **surrogate keys** in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

    More first inspections during the construction of the gold layers.
Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Check 'gold.dim_customers'
-- ====================================================================
SELECT * FROM gold.dim_customers;

-- Check for Uniqueness of Customer Key in gold.dim_customers
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- Check for the gender column (the biggest problem in this table)
SELECT distinct gender FROM gold.dim_customers;



-- ====================================================================
-- Check 'gold.product_key'
-- ====================================================================
SELECT * FROM gold.dim_products;
  
-- Check for Uniqueness of Product Key in gold.dim_products
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
SELECT * FROM gold.face_sales;

-- Check the data model connectivity between fact and dimensions
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
     ON   c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
     ON   p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL  







-- ====================================================================
-- More checks during building the gold table
-- ====================================================================
SELECT cst_id, COUNT(*) FROM
    (SELECT
      	ci.cst_id,	
      	ci.cst_key,
      	ci.cst_firstname,
      	ci.cst_lastname,
      	ci.cst_marital_status,
      	ci.cst_gndr,
      	ci.cst_create_date,
      	ca.bdate,
      	ca.gen,
      	la.cntry
    FROM silver.crm_cust_info AS ci
    LEFT JOIN silver.erp_cust_az12 as ca
         ON		ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 as la
         ON   ci.cst_key = la.cid
)t GROUP BY cst_id
HAVING COUNT(*) > 1

-- ################ product table ################
-- make sure your primary key (customer) is not duplicated
SELECT prd_id, COUNT(prd_id) FROM
    (SELECT
        pn.prd_id,
        pn.prd_key,
        pn.prd_nm,
        pn.cat_id,
        pc.cat,
        pc.subcat,
        pc.maintenance,
        pn.prd_cost,
        pn.prd_line,
        pn.prd_start_dt
    FROM silver.crm_prd_info pn
    LEFT JOIN silver.erp_px_cat_g1v2 AS pc
         ON   pn.cat_id = pc.id
    WHERE pn.prd_end_dt IS NULL -- filter out all historical data
)t GROUP BY prd_id
HAVING COUNT(*) > 1
