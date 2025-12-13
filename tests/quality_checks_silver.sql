/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks to ensure data consistency, accuracy, and standardization across the 'silver' layer. It includes checks for:
        - Null or duplicate primary keys.
        - Unwanted spaces in string fields.
        - Data standardization and consistency.
        - Invalid date ranges and orders.
        - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading the silver layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/


-- ========================== crm_cust_info table ==========================
-- Check For Nulls or Duplicates in Primary Key
-- ExpectationL No Result
SELECT
cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id is NULL;

-- Check for unwanted Spaces
-- ExpectationL No Result
-- column: cst_firstname, cst_lastname
SELECT
cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

-- Data Standardization & Consistancy
-- column: cst_marital_status, cst_gndr
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info


-- After cleaning and loading into the silver table, check again whether we successfully cleaned all problems
SELECT COUNT(*)
FROM silver.crm_cust_info

SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id is NULL

-- Check for unwanted Spaces
-- ExpectationL No Result
SELECT
cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

-- Data Standardization & Consistancy
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info


SELECT *
FROM silver.crm_cust_info




  
-- ========================== crm_prd_info table ==========================
-- Check For Nulls or Duplicates in Primary Key
-- ExpectationL No Result
SELECT
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id is NULL

-- Check for unwanted Spaces
-- ExpectationL No Result
SELECT
prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Chck for Nulls or Negative sale prices
-- Expectation: No Results
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0

-- Data Standardization & Consistancy
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

-- Check for Invalid date orders
select *
from bronze.crm_prd_info
where prd_end_dt < prd_start_dt


-- After cleaning and loading into the silver table, check again whether we successfully cleaned all problems
SELECT *
FROM silver.crm_prd_info





-- ========================== crm_sales_details table ==========================
-- Check for unwanted Spaces
SELECT *
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- Check if all the prd key are in prd_info table
SELECT *
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN
(SELECT prd_key from silver.crm_prd_info)

-- Check if all the cust key are in cust_info table
SELECT *
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN
(SELECT cst_id from silver.crm_cust_info)

-- sls_order_dt is an int, we need to change it  into date
-- Check if dt <= 0, length of dt is not 8 digits, dt out of range
-- Same procedure for sls_order_dt, sls_ship_dt
SELECT
NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8 
OR sls_order_dt > 20500101

-- Businuss Rule: sales = quantity * price
-- not negative, zeros, Nulls
SELECT
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price


-- After cleaning and loading into the silver table, check again whether we successfully cleaned all problems
SELECT *
FROM silver.crm_sales_details

SELECT *
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

SELECT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price





-- ========================== erp_cust_az12 table ==========================
-- cid does not match the data in cust_info
SELECT
cid,
bdate,
gen
FROM bronze.erp_cust_az12
WHERE cid LIKE '%00011000';

SELECT * FROM silver.crm_cust_info;

-- Check invalid birthday
SELECT
cid,
bdate,
gen
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Check gender
SELECT DISTINCT
gen as old_gen,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
	 ELSE 'n/a'
	 END AS gen
FROM bronze.erp_cust_az12


-- After cleaning and loading into the silver table, check again whether we successfully cleaned all problems
SELECT
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

SELECT
*
FROM silver.erp_cust_az12





-- ========================== erp_loc_a101 table table ==========================
SELECT
*
FROM bronze.erp_loc_a101

-- Check cid doesn't match cust_info table
SELECT 
REPLACE(cid, '-', '') AS cid 
FROM bronze.erp_loc_a101 
WHERE REPLACE(cid, '-', '') NOT IN
(SELECT cst_key FROM silver.crm_cust_info)

-- Data Standardization & Consistency
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101

SELECT
*
FROM silver.erp_loc_a101





-- ========================== erp_px_cat_glv2 table ==========================
SELECT
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2

-- Check for unwanted Spaces
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != trim(cat) OR subcat != trim(subcat) OR maintenance != TRIM(maintenance)

-- Data Standardization & Consistency
SELECT Distinct
cat
from bronze.erp_px_cat_g1v2


-- After cleaning and loading into the silver table, check again whether we successfully cleaned all problems
select *
from silver.erp_px_cat_g1v2
