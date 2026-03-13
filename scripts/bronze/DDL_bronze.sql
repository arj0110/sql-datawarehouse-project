/*========================================================
 BRONZE LAYER TABLES
 Purpose: Store raw data exactly as received from source 
 systems (CRM / ERP). No transformations are applied.
========================================================*/

/*========================================================
 TABLE: bronze_crm_cust_info
 Source: CRM System (cust_info.csv)
 Description: Stores raw customer information extracted 
 from the CRM source file.
========================================================*/

IF OBJECT_ID('bronze.crm_cust_info','U') IS NOT NULL 
    DROP TABLE bronze.crm_cust_info
CREATE TABLE bronze.crm_cust_info (

    cst_id INT,                    -- Unique customer identifier
    cst_key NVARCHAR(50),          -- Customer business key
    cst_firstname NVARCHAR(50),    -- Customer first name
    cst_lastname NVARCHAR(50),     -- Customer last name
    cst_marital_status NVARCHAR(20), -- Marital status of the customer
    cst_gndr NVARCHAR(10),         -- Gender of the customer
    cst_create_date DATE           -- Date when customer record was created
);


/*========================================================
 TABLE: bronze_crm_prd_info
 Source: ERP/Product system (prd_info.csv)
 Description: Stores raw product information.
========================================================*/
IF OBJECT_ID('bronze.crm_prd_info','U') IS NOT NULL 
    DROP TABLE bronze.crm_prd_info
CREATE TABLE bronze.crm_prd_info (

    prd_id INT,                    -- Unique product identifier
    prd_key NVARCHAR(50),          -- Product business key
    prd_nm NVARCHAR(100),          -- Product name
    prd_cost DECIMAL(10,2),        -- Cost of the product
    prd_line NVARCHAR(50),         -- Product line/category
    prd_start_dt DATE,             -- Product availability start date
    prd_end_dt DATE                -- Product availability end date
);



/*========================================================
 TABLE: bronze_crm_sales_details
 Source: Sales system (sales_details.csv)
 Description: Stores raw sales transaction data.
========================================================*/
IF OBJECT_ID('bronze.crm_sales_details','U') IS NOT NULL 
    DROP TABLE bronze.crm_sales_details
CREATE TABLE bronze.crm_sales_details (

    sls_ord_num NVARCHAR(50),      -- Sales order number
    sls_prd_key NVARCHAR(50),      -- Product key associated with the order
    sls_cust_id INT,               -- Customer identifier
    sls_order_dt INT,              -- Order date (stored as integer in source file)
    sls_ship_dt INT,               -- Shipping date
    sls_due_dt INT,                -- Due date for the order
    sls_sales DECIMAL(12,2),       -- Total sales amount
    sls_quantity INT,              -- Quantity sold
    sls_price DECIMAL(12,2)        -- Price per unit
);

/*========================================================
 BRONZE LAYER TABLES (ERP SOURCE)
 Purpose: Store raw data exactly as received from ERP CSV
 files. No transformations or business rules are applied.
========================================================*/


/*========================================================
 TABLE: bronze.erp_cust_az12
 Source File: CUST_AZ12.csv
 Description: Raw ERP customer demographic information.
========================================================*/
IF OBJECT_ID('bronze.erp_cust_az12','U') IS NOT NULL 
    DROP TABLE bronze.erp_cust_az12
CREATE TABLE bronze.erp_cust_az12 (

    CID NVARCHAR(50),        -- Customer identifier from ERP system
    BDATE DATE,              -- Customer birth date
    GEN NVARCHAR(20)         -- Customer gender

);

/*========================================================
 TABLE: bronze.erp_loc_a101
 Source File: LOC_A101.csv
 Description: Raw ERP customer location information.
========================================================*/
IF OBJECT_ID('bronze.erp_loc_a101','U') IS NOT NULL 
    DROP TABLE bronze.erp_loc_a101
CREATE TABLE bronze.erp_loc_a101 (

    CID NVARCHAR(50),        -- Customer identifier used to link with customer table
    CNTRY NVARCHAR(50)       -- Country of the customer

);


/*========================================================
 TABLE: bronze.erp_px_cat_g1v2
 Source File: PX_CAT_G1V2.csv
 Description: Raw ERP product category and classification.
========================================================*/
IF OBJECT_ID('bronze.erp_px_cat_g1v2','U') IS NOT NULL 
    DROP TABLE bronze.erp_px_cat_g1v2
CREATE TABLE bronze.erp_px_cat_g1v2 (

    ID NVARCHAR(50),          -- Product category identifier
    CAT NVARCHAR(100),        -- Product category name
    SUBCAT NVARCHAR(100),     -- Product sub-category
    MAINTENANCE NVARCHAR(10)  -- Indicates if maintenance service is required

);
