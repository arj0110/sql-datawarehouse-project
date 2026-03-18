/*
====================================================================
Quality Checks – Silver Layer
====================================================================

Script Purpose:
This script performs quality checks to validate the integrity,
consistency, and accuracy of the Silver layer. These checks ensure:

- Data is cleaned and standardized properly from Bronze layer.
- No duplicate or invalid records exist.
- Business rules are correctly applied.
- Data is ready for Gold layer transformations.

Usage Notes:
- Run after executing silver.load_silver procedure.
- Investigate any discrepancies returned by the queries.
====================================================================
*/


-- ================================================================
-- Checking 'silver.crm_cust_info'
-- ================================================================

-- Check for unwanted spaces in customer names
-- Expectation: No results
SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Check distribution of gender values
-- Expectation: Only 'Male', 'Female', 'n/a'
SELECT cst_gndr, COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_gndr;

-- Check distribution of marital status
-- Expectation: Only 'Single', 'Married', 'n/a'
SELECT cst_marital_status, COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_marital_status;



-- ================================================================
-- Checking 'silver.crm_prd_info'
-- ================================================================

-- Check for duplicate or NULL product IDs
-- Expectation: No results
SELECT prd_id, COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted spaces in product names
-- Expectation: No results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for invalid product cost (NULL or negative)
-- Expectation: No results
SELECT prd_cost, COUNT(*)
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL
GROUP BY prd_cost;

-- Check product line distribution
-- Expectation: Standardized values only
SELECT prd_line, COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_line;

-- Check for NULL end dates in Bronze (before transformation)
SELECT prd_end_dt, COUNT(*)
FROM bronze.crm_prd_info
WHERE prd_end_dt IS NULL
GROUP BY prd_end_dt;

-- Validate product date continuity logic
SELECT 
    prd_id,
    prd_key,
    prd_start_dt,
    prd_end_dt,
    LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS next_start_dt
FROM bronze.crm_prd_info;



-- ================================================================
-- Checking 'silver.crm_sales_details'
-- ================================================================

-- Check for duplicate or NULL order numbers
-- Expectation: No results
SELECT sls_ord_num, COUNT(*)
FROM silver.crm_sales_details
GROUP BY sls_ord_num
HAVING COUNT(*) > 1 OR sls_ord_num IS NULL;

-- Check for duplicate product keys
-- Expectation: No results
SELECT sls_prd_key, COUNT(*)
FROM silver.crm_sales_details
GROUP BY sls_prd_key
HAVING COUNT(*) > 1 OR sls_prd_key IS NULL;

-- Check for NULL customer IDs in Bronze
SELECT sls_cust_id
FROM bronze.crm_sales_details
WHERE sls_cust_id IS NULL;

-- Validate date conversion issues
SELECT sls_order_dt, TRY_CAST(sls_order_dt AS DATETIME)
FROM bronze.crm_sales_details
WHERE TRY_CAST(sls_order_dt AS DATETIME) IS NULL
AND sls_order_dt IS NOT NULL;

-- Check invalid date formats
SELECT NULLIF(sls_order_dt,0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt = 0 OR LEN(sls_order_dt) != 8;

-- Check for negative or NULL sales values
SELECT sls_sales,
CASE 
    WHEN sls_sales < 0 THEN 0
    ELSE sls_sales
END AS corrected_sales
FROM bronze.crm_sales_details
WHERE sls_sales IS NULL OR sls_sales < 0;

-- Check invalid date relationships
-- Expectation: No results
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_due_dt 
   OR sls_order_dt > sls_ship_dt 
   OR sls_due_dt < sls_ship_dt;

-- Validate sales and price calculations
SELECT
sls_sales AS old_sales,
sls_quantity,
sls_price AS old_price,

CASE 
    WHEN sls_sales IS NULL OR sls_sales < 0 
         OR sls_sales != ABS(sls_price * sls_quantity)
    THEN ABS(sls_price * sls_quantity)
    ELSE sls_sales
END AS corrected_sales,

CASE 
    WHEN sls_price <= 0 OR sls_price IS NULL 
    THEN CAST(ABS(sls_sales / sls_quantity) AS INT)
    ELSE sls_price
END AS corrected_price

FROM bronze.crm_sales_details
WHERE sls_sales != sls_price * sls_quantity
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL;



-- ================================================================
-- Checking 'silver.erp_cust_az12'
-- ================================================================

-- Validate customer ID transformation
SELECT cid, SUBSTRING(cid,4,LEN(cid))
FROM bronze.erp_cust_az12
WHERE cid LIKE 'NAS%';

-- Check invalid birthdates
-- Expectation: No future dates or very old dates
SELECT BDATE
FROM bronze.erp_cust_az12
WHERE BDATE > GETDATE() OR BDATE < '1920-01-01';

-- Validate gender transformation
SELECT GEN,
CASE 
    WHEN GEN = 'F' THEN 'Female'
    WHEN GEN = 'M' THEN 'Male'
    WHEN GEN = ' ' OR GEN IS NULL THEN 'n/a'
    ELSE GEN
END AS standardized_gen
FROM bronze.erp_cust_az12;



-- ================================================================
-- Checking 'silver.erp_loc_a101'
-- ================================================================

-- Validate customer ID cleanup
SELECT DISTINCT CID,
REPLACE(cid,'-','') AS cleaned_cid
FROM bronze.erp_loc_a101;

-- Validate country normalization
SELECT DISTINCT CNTRY,
CASE 
    WHEN TRIM(CNTRY) IS NULL OR TRIM(CNTRY) = '' THEN 'n/a'
    WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
    WHEN TRIM(CNTRY) IN ('US','USA') THEN 'United States'
    ELSE CNTRY
END AS standardized_country
FROM bronze.erp_loc_a101;



-- ================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ================================================================

-- Check invalid category IDs
-- Expectation: No NULLs and length = 5
SELECT ID
FROM bronze.erp_px_cat_g1v2
WHERE ID IS NULL OR LEN(ID) != 5;

-- Validate category values
SELECT DISTINCT CAT
FROM bronze.erp_px_cat_g1v2;
