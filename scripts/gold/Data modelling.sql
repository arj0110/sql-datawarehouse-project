-- =============================================
-- GOLD LAYER: DATA MODELING (STAR SCHEMA)
-- This layer contains business-ready data models
-- Includes:
--   - Dimension tables (descriptive attributes)
--   - Fact tables (transactional/measurable data)
-- OBJECT TYPE : VIEWS
-- =============================================


-- =============================================
-- DIMENSION TABLE: CUSTOMERS
-- Purpose: Stores customer attributes for analysis
-- Grain: One record per customer
-- =============================================
CREATE OR ALTER VIEW gold.dim_customers AS 
SELECT
    -- Surrogate key generated for dimensional modeling
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,

    -- Business keys
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,

    -- Customer attributes
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    la.cntry AS country,

    -- Gender logic: prioritize CRM, fallback to ERP
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,

    ci.cst_marital_status AS marital_status,
    ca.bdate AS birthdate,

    -- Metadata
    ci.cst_create_date AS create_date	

FROM silver.crm_cust_info ci

-- Join ERP system for additional attributes
LEFT JOIN silver.erp_cust_az12 ca
    ON ca.cid = ci.cst_key

LEFT JOIN silver.erp_loc_a101 la
    ON la.cid = ci.cst_key

-- Exclude invalid records
WHERE ci.cst_id IS NOT NULL;


-- =============================================
-- DIMENSION TABLE: PRODUCTS
-- Purpose: Stores product-related attributes
-- Grain: One record per active product
-- =============================================
CREATE OR ALTER VIEW gold.dim_products AS 
SELECT
    -- Surrogate key
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,

    -- Business keys
    pn.prd_id AS product_id,
    pn.prd_key AS product_number,

    -- Product attributes
    pn.prd_nm AS product_name,
    pn.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,

    -- Standardized numeric fields
    CAST(pn.prd_cost AS INT) AS product_cost,

    pn.prd_line AS product_line,
    pn.prd_start_dt AS product_start_date,
    pn.prd_end_dt AS product_end_date

FROM silver.crm_prd_info pn

-- Join product category details
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pc.id = pn.cat_id

-- Only include active products
WHERE pn.prd_end_dt IS NULL;


-- =============================================
-- FACT TABLE: SALES
-- Purpose: Stores transactional sales data
-- Grain: One record per sales transaction
-- =============================================
CREATE OR ALTER VIEW gold.fact_sales AS 
SELECT	
    -- Transaction identifiers
    sd.sls_ord_num AS order_number,

    -- Foreign keys (link to dimensions)
    pr.product_key,
    cu.customer_key,

    -- Dates
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,

    -- Measures (business metrics)
    CAST(sd.sls_sales AS INT) AS sales,
    sd.sls_quantity AS quantity,
    CAST(sd.sls_price AS INT) AS price

FROM silver.crm_sales_details sd

-- Join with product dimension
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number

-- Join with customer dimension
LEFT JOIN gold.dim_customers cu
    ON cu.customer_id = sd.sls_cust_id;
