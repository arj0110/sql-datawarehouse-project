/*
====================================================================
Quality Checks – Gold Layer
====================================================================

Script Purpose:
This script validates the final analytical layer (Gold),
ensuring data consistency, correctness, and proper joins 
between fact and dimension tables.

These checks ensure:
- Business logic is correctly applied
- Dimensions are properly integrated
- Fact table relationships are intact
- Data is analytics-ready

Usage Notes:
- Run after Gold layer views/tables are created
- Investigate any unexpected results
====================================================================
*/


-- ================================================================
-- Checking 'gold.dim_customers' (Gender Logic Validation)
-- ================================================================

-- Validate gender consolidation logic between CRM and ERP
-- Expectation: Priority to CRM data, fallback to ERP, no unexpected values
SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,

	CASE 
		WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr      -- CRM is treated as primary source
		ELSE COALESCE(ca.gen,'n/a')                     -- Fallback to ERP if CRM is missing
	END AS gender

FROM silver.crm_cust_info ci

LEFT JOIN silver.erp_cust_az12 ca
	ON ca.cid = ci.cst_key                           -- Join ERP customer data

LEFT JOIN silver.erp_loc_a101 la
	ON la.cid = ci.cst_key                           -- Join location data (optional enrichment)

ORDER BY 1,2;



-- ================================================================
-- Checking 'gold.fact_sales' Referential Integrity
-- ================================================================

-- Check for missing product references in fact table
-- Expectation: No NULL product_key matches (all facts should map to dimension)
SELECT *
FROM gold.fact_sales g

LEFT JOIN gold.dim_customers c
	ON c.customer_key = g.customer_key               -- Validate customer dimension join

LEFT JOIN gold.dim_products p
	ON p.product_key = g.product_key                -- Validate product dimension join

WHERE p.product_key IS NULL;                       -- Identify broken product relationships
