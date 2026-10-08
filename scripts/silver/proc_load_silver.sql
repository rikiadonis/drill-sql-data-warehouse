/*
==========================================================================================
Srored Procedure: Load Silver Layer
==========================================================================================
Script Purpose:
  This stored procedure performs the ETL (Extract, Transform, Load) process to 
  populate the 'silver' schema tables from the 'bronze' schema.
Action Performed:
  - Truncates Silver Tables.
  - Inserts transformed and cleansed data from Bronze into Silver tables.
Parameters:
  None.
  This stored procedure does not accept any parameters yet any valus.
Usage Exampe:
  EXEC silver.load_silver;
=========================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	BEGIN TRY
		DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
		SET @batch_start_time = GETDATE()
		PRINT('==================================================================')
		PRINT('Loading Silver Layer')
		PRINT('==================================================================')

		PRINT('------------------------------------------------------------------')
		PRINT('Loading CMR Tables')
		PRINT('------------------------------------------------------------------')

		SET @start_time = GETDATE()
		PRINT('>> Tuncating Table: silver.cmr_cust_info')
		TRUNCATE TABLE silver.cmr_cust_info
		PRINT('>> Insert Data Into: silver.cmr_cust_info')
		INSERT INTO silver.cmr_cust_info(cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) cst_firstname,
			TRIM(cst_lastname) cst_lastname,
			CASE
				WHEN TRIM(UPPER(cst_marital_status)) = 'M' THEN 'Married'
				WHEN TRIM(UPPER(cst_marital_status)) = 'S' THEN 'Single'
				ELSE 'n/a'
			END cst_marital_status,
			CASE
				WHEN TRIM(UPPER(cst_gndr)) = 'M' THEN 'Male'
				WHEN TRIM(UPPER(cst_gndr)) = 'F' THEN 'Female'
				ELSE 'n/a'
			END cst_gndr,
			cst_create_date
		FROM
			(	SELECT
					*,
					ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) f
				FROM bronze.cmr_cust_info
			) t
		WHERE f = 1 AND cst_id IS NOT NULL
		SET @end_time = GETDATE()
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds')
		PRINT('--------------------------------------------------------------------------------------------------')
		PRINT('--------------------------------------------------------------------------------------------------')

		SET @start_time = GETDATE()
		PRINT('>> Truncating Table: silver.cmr_pd_info')
		TRUNCATE TABLE silver.cmr_prd_info
		PRINT('>> Insert Data Into: silver.cmr_prd_info')
		INSERT INTO silver.cmr_prd_info(prd_id, prd_num, cat_id, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
		SELECT
			prd_id,
			SUBSTRING(prd_key, 1, 5) prd_num,
			SUBSTRING(prd_key, 7, LEN(prd_key)) cat_id,
			prd_nm,
			ISNULL(prd_cost, 0) prd_cost,
			CASE prd_line
				WHEN 'R'THEN 'Road'
				WHEN 'M' THEN 'Mountain'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
			END prd_line,
			CAST(prd_start_dt AS DATE) prd_start_dt,
			CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_nm ORDER BY prd_start_dt) - 1 AS DATE)  prd_end_dt
		FROM bronze.cmr_prd_info
		SET @end_time = GETDATE()
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time)AS NVARCHAR) + ' milliseconds')
		PRINT('--------------------------------------------------------------------------------------------------')
		PRINT('--------------------------------------------------------------------------------------------------')

		SET @start_time = GETDATE()
		PRINT('>> Trunacating Table: silver.cmr_sales_details')
		TRUNCATE TABLE silver.cmr_sales_details
		PRINT('>> Insert Data Into: silver.cmr_sales_details')
		INSERT INTO silver.cmr_sales_details(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE
				WHEN LEN(sls_order_dt) = 8 THEN CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
				ELSE NULL
			END sls_order_dt,
			CASE
				WHEN LEN(sls_ship_dt) = 8 THEN CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
				ELSE NULL
			END sls_ship_dt,
			CASE 
				WHEN LEN(sls_due_dt) = 8 THEN CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
				ELSE NULL
			END sls_due_dt,
			CASE 
				WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != ABS(sls_price) * sls_quantity THEN ABS(sls_price) * sls_quantity
				ELSE sls_sales
			END sls_sales,
			sls_quantity,
			CASE
				WHEN sls_price IS NULL OR sls_price <= 0 THEN ABS(sls_sales)/ NULLIF(sls_quantity, 0)
				ELSE sls_price
			END sls_price
		FROM bronze.cmr_sales_details
		SET @end_time = GETDATE()
		PRINT('Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds')
		PRINT('--------------------------------------------------------------------------------------------------')
		PRINT('--------------------------------------------------------------------------------------------------')

		PRINT('---------------------------------------------------------------------------------')
		PRINT('Loading ERP Tables')
		PRINT('---------------------------------------------------------------------------------')
		SET @start_time = GETDATE()
		PRINT('>> Truncating Table: silver.erp_cust_az12')
		TRUNCATE TABLE silver.erp_cust_az12
		PRINT('>> Insert Into Data: silver.erp_cust_az12')
		INSERT INTO silver.erp_cust_az12(cid, bdate, gen)
		SELECT
			CASE 
				WHEN SUBSTRING(UPPER(TRIM(cid)), 1,3) = 'NAS' 
				THEN SUBSTRING(UPPER(TRIM(cid)), 4, LEN(cid))
				ELSE UPPER(TRIM(cid))
			END cid, 
			bdate,
			CASE
				WHEN ca.gen IS NULL THEN ci.cst_gndr
				ELSE ca.gen
			END gen
		FROM bronze.erp_cust_az12 ca
		LEFT JOIN silver.cmr_cust_info ci ON ca.cid = ci.cst_key
		SET @end_time = GETDATE()
		PRINT('>> Load Duartion: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time)AS NVARCHAR) + ' milliseconds')
		PRINT('--------------------------------------------------------------------------------------------------')
		PRINT('--------------------------------------------------------------------------------------------------')
		
		SET @start_time = GETDATE()
		PRINT('>> Truncating Table: silver.erp_loc_a101')
		TRUNCATE TABLE silver.erp_loc_a101
		PRINT('>> Insert data Into: silver.erp_loc_a101')
		INSERT INTO silver.erp_loc_a101(cid, cntry)
		SELECT
			REPLACE(UPPER(TRIM(cid)), '-', '') cid,
			CASE
				WHEN UPPER(TRIM(cntry)) IN ('AU', 'AUS') THEN 'Australia'
				WHEN UPPER(TRIM(cntry)) IN ('CA', 'CAN') THEN 'Canada'
				WHEN UPPER(TRIM(cntry)) IN ('FR', 'FRA') THEN 'France'
				WHEN UPPER(TRIM(cntry)) IN ('DE', 'DEU') THEN 'Germany'
				WHEN UPPER(TRIM(cntry)) IN ('GB', 'GBR', 'UK') THEN 'United Kingdom'
				WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM(cntry)
			END cntry
		FROM bronze.erp_loc_a101
		SET @end_time = GETDATE()
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds')
		PRINT('--------------------------------------------------------------------------------------------------')
		PRINT('--------------------------------------------------------------------------------------------------')

		SET @start_time = GETDATE()
		PRINT('>> Truncating Table: silver.erp_px_cat_g1v2')
		TRUNCATE TABLE silver.erp_px_cat_g1v2
		PRINT('>> Insert data Into: silver.erp_px_g1v2')
		INSERT INTO silver.erp_px_cat_g1v2(id, cat, subcat, maintenance)
		SELECT 
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2
		SET @end_time = GETDATE()
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' milliseconds')
		PRINT('--------------------------------------------------------------------------------------------------')
		PRINT('--------------------------------------------------------------------------------------------------')

		SET @batch_end_time = GETDATE()
		PRINT('>> Silver Layer Load Successfully')
		PRINT('	- Toatl Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' milliseconds')
		PRINT('---------------------------------------------------------------------------------------------------')
		PRINT('---------------------------------------------------------------------------------------------------')
	END TRY

	BEGIN CATCH
		PRINT('An Error Occurred')
		PRINT('Error Message: '  + ERROR_MESSAGE())
		PRINT('Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR))
		PRINT('Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR))
		PRINT('Error Procedure: '+ CAST(ERROR_PROCEDURE() AS NVARCHAR))
	END CATCH
END;
