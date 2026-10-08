-- Data Standardization & Consistency
/*
======================================================
Quality Checks
======================================================
Script Purpose:
	This script performs various quality checks for data consistency, accurary, 
	and standardization accross the 'silver' schemas. It includes checks for:
	- Null or duplicate primary keys.
	- Unwanted spaces in strings fields.
	- Invalid date range and orders.
	- data consistency between related fields.
	
Usage Notes:
	- Run these checks after data loading Silver Layer.
	- Investigate and resolve any discrepancises found during the checks.
=======================================================
*/

-- ======================================================
-- Checking 'silver.cmr_cust_info'
-- ======================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results

SELECT
	cst_id
	COUNT(*)
FROM silver.cmr_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Chceck for Unwanted Spaces
-- Expecation: No Results
SELECT 
	cst_key 
FROM silver.cmr_cust_info
WHERE cst_key != TRIM(cst_key)

-- Data Standardization & Consistency
SELECT DISTINCT
	cst_marital_status
FROM silver.cmr_cust_info;

--=====================================================
-- Checking silver.cmr_prd_info
-- =====================================================
-- Chck for NULLs or Duplicates in Primary Keys
-- Excpectation: No Results
SELECT
	prd_id,
	COUNT(*)
FROM silver.cmr_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
OR prd_key IS NULL 

-- Chcek for Unwanted Spaces
-- Expectation: No Results
SELECT
	prd_nm
FROM silver.cmr_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Chcek for NULLs or Negative values in Costs
-- Expecation: No Results
SELECT
	prd_cost
FROM silver.cmr_prd_info
WHERE prd_cost IS NULL 
OR prd_cost < 0

-- Data Standardization & Consistency
SELECT DISTINCT 
	prd_line
FROM silver.cmr_prd_info

-- Chceck for invalid date Orders (Start Date & End Date)
-- Expecation: No Results
SELECT
	*
FROM silver.cmr_prd_info
WHERE prd_start_dt < prd_end_dt
-- =====================================================
-- Checking silver.cmr_sales_details
-- =====================================================
-- Check for Invalid Dates
-- Expectation: No Invalid Dates 
SELECT 
	NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.cmr_sales_details
WHERE sls_due_dt <= 0
OR sls_due_dt != 8
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101;

-- Check for Inavlid Date Orders (Order Date > Shipping/Due Date)
-- Expecation: No Results
SELECT
	sls_order_dt
FROM silver.cmr_sales_details
WHERE sls_order_dt > sls_ship_dt
OR sls_order_dt > sls_due_dt

-- Check Data Consistency: Sales = Quantity * Price
-- Expecation: No Results
SELECT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.cmr_sales_details
WHERE sls_sales != sls_quantity * Price
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales <= 0
OR sls_quantity <= 0
OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

-- =====================================================
-- Checking 'silver.erp_cust_az12'
-- =====================================================
-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today
SELECT
	*
FROM silver.erp_cust_az12
WHERE bdate BETWEEN '1924-01-01' AND GETDATE()

-- Data Standardization & Consistency
SELECT DISTINCT
	gen
FROM silver.erp_cust_az12 

-- =====================================================
-- Checking 'silver.erp_loc_a101'
-- =====================================================
-- Data Standardization & Consistency
SELECT DISTINCT
	cntry
FROM silver.erp_loc_a101
ORDER BY cntry

-- =====================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- =====================================================
-- Check for Unwanted Spaces 
-- Expectation: No Results
SELECT
	*
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
	OR subcat != TRIM(subcat)
	OR maintenance != TRIM(maintenence)

-- Data Stardadization & Consistency

