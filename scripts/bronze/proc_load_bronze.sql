/*
=========================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
=========================================================================
Script Purpose:
  This stored procedure loads data into the 'bronze' schema from external CSV files.
  It performs the following action.
  - Truncates the bronze tables before leading data.
  - Uses the 'BULK INSERT' command to load data from CSV files to bronze tables.

Parameters:
  None.
  This stored procedure does not accept any parameters or return any values.

Usage Exmaple:
  EXEC bronze.load_bronze;
==========================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze 
AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
		SET @batch_start_time = GETDATE()
		PRINT('======================================================')
		PRINT('Loading Bronze Layer')
		PRINT('======================================================')
		PRINT('Load CMR Tables')
		PRINT('------------------------------------------------------')
		SET @start_time = GETDATE()
		PRINT('>> Truncating table: bronze.cmr_cust_info')
		TRUNCATE TABLE bronze.cmr_cust_info
		PRINT('>> Inserting Data Into: bronze.cmr_cust_info')
		BULK INSERT bronze.cmr_cust_info
		FROM 'C:\Users\barti\Desktop\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds.')
		PRINT('--------------------------------------------------------')
		SET @start_time = GETDATE()
		PRINT('>> Truncating Table: bronze.cmr_prd_info')
		TRUNCATE TABLE bronze.cmr_prd_info
		PRINT('>> Inserting Data Into: bronze.cmr_prd_info')
		BULK INSERT bronze.cmr_prd_info
		FROM 'C:\Users\barti\Desktop\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds')
		PRINT('---------------------------------------------------------')
		SET @start_time = GETDATE()
		PRINT('>> Truncating Table: bronze.cmr_sales_details')
		TRUNCATE TABLE bronze.cmr_sales_details
		PRINT('>> Inserting Data Into: bronze.cmr_sales_details')
		BULK INSERT bronze.cmr_sales_details
		FROM 'C:\Users\barti\Desktop\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds')
		PRINT('----------------------------------------------------------')
		PRINT('Load ERP Tables')
		PRINT('----------------------------------------------------------')
		SET @start_time = GETDATE()
		PRINT('>> Truncating Table: bronze.erp_cust_az12')
		TRUNCATE TABLE bronze.erp_cust_az12
		PRINT('>> Inserting Data Into: bronze.erp_cust_az12')
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\barti\Desktop\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\cust_az12.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT('Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds.')
		PRINT('---------------------------------------------------------------------')
		
		SET @start_time = GETDATE()
		PRINT('>> Truncating Table: bronze.erp_loc_a101')
		TRUNCATE TABLE bronze.erp_loc_a101
		PRINT('>> Iserting Data Into: bronze.erp_loc_a101')
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\barti\Desktop\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\loc_a101.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT('Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds.')
		PRINT('--------------------------------------------------------------')
		
		SET @start_time = GETDATE()
		PRINT('>> Truncating Table: bronze.erp_px_cat_g1v2')
		TRUNCATE TABLE bronze.erp_px_cat_g1v2
		PRINT('>> Inserting Data Into: bronze.erp_px_cat_g1v2')
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\barti\Desktop\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\px_cat_g1v2.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			)
		SET @end_time = GETDATE()
		SET @batch_end_time = GETDATE()
		PRINT('Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds.')
		PRINT('-----------------------------------------------------------------------')
		PRINT('Load Bronze Layer is completed')
		PRINT('Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds.')
	END TRY

	BEGIN CATCH
		PRINT('-------------------------------------------------------')
		PRINT('An Error Occurred')
		PRINT('ERROR MESSAGE: ' + ERROR_MESSAGE())
		PRINT('ERROR LINE: ' + CAST(ERROR_LINE() AS NVARCHAR))
		PRINT('ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR))
		PRINT('ERROR PRODEDURE: ' + CAST(ERROR_PROCEDURE() AS NVARCHAR))
		PRINT('--------------------------------------------------------')
	END CATCH
END
