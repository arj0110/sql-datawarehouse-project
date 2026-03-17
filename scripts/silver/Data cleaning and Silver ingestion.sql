CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN

DECLARE @start_time DATETIME, 
        @end_time DATETIME,
        @batch_start DATETIME;

BEGIN TRY

PRINT '========================================';
PRINT 'Starting Silver Layer Load';
PRINT '========================================';

SET @batch_start = GETDATE();


-------------------------------------------------
-- CRM CUSTOMER INFO
-------------------------------------------------

PRINT 'Loading silver.crm_cust_info';
SET @start_time = GETDATE();

TRUNCATE TABLE silver.crm_cust_info;

INSERT INTO silver.crm_cust_info
(
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
)
SELECT 
[cst_id],
[cst_key],
TRIM(cst_firstname),
TRIM(cst_lastname),

CASE 
	when cst_marital_status = 'S' then 'Single'
	when cst_marital_status = 'M' then 'Married'
	else 'n/a'
END,

CASE 
	when cst_gndr = 'F' then 'Female'
	when cst_gndr = 'M' then 'Male'
	else 'n/a'
END,

cst_create_date
FROM
(
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) rn
	FROM bronze.crm_cust_info
)t
WHERE rn = 1;

SET @end_time = GETDATE();
PRINT 'crm_cust_info load completed in ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR) + ' seconds';


-------------------------------------------------
-- CRM PRODUCT INFO
-------------------------------------------------

PRINT 'Loading silver.crm_prd_info';
SET @start_time = GETDATE();

TRUNCATE TABLE silver.crm_prd_info;

INSERT INTO silver.crm_prd_info
(
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)
SELECT 
prd_id,

REPLACE(LEFT(prd_key,5),'-','_'),

SUBSTRING(prd_key,7,LEN(prd_key)),

prd_nm,

COALESCE(prd_cost,0),

CASE 
	WHEN prd_line = 'M' THEN 'Mountain'
	WHEN prd_line = 'R' THEN 'Road'
	WHEN prd_line = 'S' THEN 'Other Sales'
	WHEN prd_line = 'T' THEN 'Touring'
	ELSE 'n/a'
END,

prd_start_dt,

DATEADD(day,-1,
LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)
)

FROM bronze.crm_prd_info;

SET @end_time = GETDATE();
PRINT 'crm_prd_info load completed in ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR) + ' seconds';


-------------------------------------------------
-- CRM SALES DETAILS
-------------------------------------------------

PRINT 'Loading silver.crm_sales_details';
SET @start_time = GETDATE();

TRUNCATE TABLE silver.crm_sales_details;

INSERT INTO silver.crm_sales_details
(
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
)

SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,

CASE
WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
END,

CASE
WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
END,

CASE
WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
END,

CASE 
WHEN sls_sales IS NULL 
OR sls_sales <= 0
OR sls_sales != ABS(sls_price*sls_quantity)
THEN ABS(sls_price*sls_quantity)
ELSE sls_sales
END,

sls_quantity,

CASE 
WHEN sls_price <=0 OR sls_price IS NULL
THEN CAST(ABS(sls_sales/sls_quantity) AS INT)
ELSE sls_price
END

FROM bronze.crm_sales_details;

SET @end_time = GETDATE();
PRINT 'crm_sales_details load completed in ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR) + ' seconds';


-------------------------------------------------
-- ERP CUSTOMER
-------------------------------------------------

PRINT 'Loading silver.erp_cust_az12';
SET @start_time = GETDATE();

TRUNCATE TABLE silver.erp_cust_az12;

INSERT INTO silver.erp_cust_az12
(
cid,
bdate,
gen
)

SELECT 

CASE 
WHEN CID LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(CID))
ELSE CID
END,

CASE 
WHEN BDATE > GETDATE() THEN NULL
ELSE BDATE
END,

CASE 
WHEN GEN = 'F' THEN 'Female'
WHEN GEN = 'M' THEN 'Male'
WHEN GEN = ' ' OR GEN IS NULL THEN 'n/a'
ELSE GEN
END

FROM bronze.erp_cust_az12;

SET @end_time = GETDATE();
PRINT 'erp_cust_az12 load completed in ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR) + ' seconds';


-------------------------------------------------
-- ERP LOCATION
-------------------------------------------------

PRINT 'Loading silver.erp_loc_a101';
SET @start_time = GETDATE();

TRUNCATE TABLE silver.erp_loc_a101;

INSERT INTO silver.erp_loc_a101
(
cid,
cntry
)

SELECT 

REPLACE(cid,'-',''),

CASE 
WHEN TRIM(CNTRY) IS NULL OR TRIM(CNTRY) = '' THEN 'n/a'
WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
WHEN TRIM(CNTRY) IN ('US','USA') THEN 'United States'
ELSE CNTRY
END

FROM bronze.erp_loc_a101;

SET @end_time = GETDATE();
PRINT 'erp_loc_a101 load completed in ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR) + ' seconds';


-------------------------------------------------
-- ERP PRODUCT CATEGORY
-------------------------------------------------

PRINT 'Loading silver.erp_px_cat_g1v2';
SET @start_time = GETDATE();

TRUNCATE TABLE silver.erp_px_cat_g1v2;

INSERT INTO silver.erp_px_cat_g1v2
(
ID,
CAT,
SUBCAT,
MAINTENANCE
)

SELECT 
ID,
CAT,
SUBCAT,
MAINTENANCE
FROM bronze.erp_px_cat_g1v2;

SET @end_time = GETDATE();
PRINT 'erp_px_cat_g1v2 load completed in ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR) + ' seconds';


-------------------------------------------------
-- TOTAL LOAD TIME
-------------------------------------------------

PRINT '========================================';
PRINT 'Silver Layer Load Completed';
PRINT 'Total Duration: ' + CAST(DATEDIFF(SECOND,@batch_start,GETDATE()) AS VARCHAR) + ' seconds';
PRINT '========================================';


END TRY

BEGIN CATCH

PRINT 'ERROR OCCURRED DURING SILVER LOAD';
PRINT ERROR_MESSAGE();

END CATCH

END

EXEC silver.load_silver;