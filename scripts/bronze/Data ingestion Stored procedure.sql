/*==============================================================
  DATABASE CONTEXT
==============================================================*/
USE Datawarehouse;
GO


/*==============================================================
  STORED PROCEDURE: bronze.load_bronze

  PURPOSE:
  Load raw CRM and ERP CSV files into Bronze layer tables.

  STRATEGY:
  Full refresh load using TRUNCATE + BULK INSERT
==============================================================*/

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN

PRINT '============================================';
PRINT 'Starting Bronze Layer Data Load';
PRINT '============================================';


/*==============================================================
  LOAD CRM CUSTOMER INFORMATION
==============================================================*/

PRINT 'Loading CRM Customer Information...';

TRUNCATE TABLE bronze.crm_cust_info;

BULK INSERT bronze.crm_cust_info
FROM 'C:\Users\ANKIT\Documents\SQL Datawarehouse Project\datasets\source_crm\cust_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

PRINT 'CRM Customer Information Loaded Successfully';


/*==============================================================
  LOAD CRM PRODUCT INFORMATION
==============================================================*/

PRINT 'Loading CRM Product Information...';

TRUNCATE TABLE bronze.crm_prd_info;

BULK INSERT bronze.crm_prd_info
FROM 'C:\Users\ANKIT\Documents\SQL Datawarehouse Project\datasets\source_crm\prd_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

PRINT 'CRM Product Information Loaded Successfully';



/*==============================================================
  LOAD CRM SALES DETAILS
==============================================================*/

PRINT 'Loading CRM Sales Details...';

TRUNCATE TABLE bronze.crm_sales_details;

BULK INSERT bronze.crm_sales_details
FROM 'C:\Users\ANKIT\Documents\SQL Datawarehouse Project\datasets\source_crm\sales_details.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

PRINT 'CRM Sales Details Loaded Successfully';



/*==============================================================
  LOAD ERP CUSTOMER DATA
==============================================================*/

PRINT 'Loading ERP Customer Data...';

TRUNCATE TABLE bronze.erp_cust_az12;

BULK INSERT bronze.erp_cust_az12
FROM 'C:\Users\ANKIT\Documents\SQL Datawarehouse Project\datasets\source_erp\CUST_AZ12.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

PRINT 'ERP Customer Data Loaded Successfully';



/*==============================================================
  LOAD ERP CUSTOMER LOCATION DATA
==============================================================*/

PRINT 'Loading ERP Customer Location Data...';

TRUNCATE TABLE bronze.erp_loc_a101;

BULK INSERT bronze.erp_loc_a101
FROM 'C:\Users\ANKIT\Documents\SQL Datawarehouse Project\datasets\source_erp\LOC_A101.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

PRINT 'ERP Customer Location Data Loaded Successfully';



/*==============================================================
  LOAD ERP PRODUCT CATEGORY DATA
==============================================================*/

PRINT 'Loading ERP Product Category Data...';

TRUNCATE TABLE bronze.erp_px_cat_g1v2;

BULK INSERT bronze.erp_px_cat_g1v2
FROM 'C:\Users\ANKIT\Documents\SQL Datawarehouse Project\datasets\source_erp\PX_CAT_G1V2.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

PRINT 'ERP Product Category Data Loaded Successfully';



PRINT '============================================';
PRINT 'Bronze Layer Data Load Completed';
PRINT '============================================';

END;
GO


-- Execute the procedure
EXEC bronze.load_bronze;