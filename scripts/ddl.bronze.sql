USE DrillDataWarehouse;
GO
IF OBJECT_ID('bronze.cmr_cust_info', 'U') IS NOT NULL
  DROP TABLE bronze.cmr_cust_info;
CREATE TABLE bronze.cmr_cust_info (
  cst_id INT,
  cst_key NVARCHAR(50),
  cst_firstname NVARCHAR(50),
  cst_lastname NVARCHAR(50),
  cst_marital_status NVARCHAR(50),
  cst_gndr NVARCHAR(50),
  cst_create_date DATE
);
GO
IF OBJECT_ID('bronze.cmr_prd_info', 'U') IS NOT NULL
  DROP TABLE bronze.cmr_prd_info;
CREATE TABLE bronze.cmr_prd_info(
  prd_id INT,
  prd_key NVARCHAR(50),
  prd_nm NVARCHAR(50),
  prd_cost NVARCHAR(50),
  prd_line NVARCHAR(50),
  prd_start_dt DATETIME,
  prd_end_dt DATETIME
);
GO
IF OBJECT_ID('bronze.cmr_sales_details', 'U') IS NOT NULL
  DROP TABLE bronze.cmr_sales_details;
CREATE TABLE bronze.cmr_sales_details(
  sls_ord_num NVARCGAR(50),
  sls_prd_key NVARCHAR(50),
  sls_cust_id INT,
  sls_order_dt INT,
  sls_ship_dt INT,
  sls_due_dt INT,
  sls_sales INT,
  sls_quantity INT,
  sls_price INT
);
GO
