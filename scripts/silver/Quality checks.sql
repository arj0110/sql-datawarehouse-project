-- Customer info table
select cst_lastname
from bronze.crm_cust_info
where cst_lastname!=TRIM(cst_lastname);

select cst_gndr,count(*)
from bronze.crm_cust_info
group by cst_gndr

select cst_marital_status,count(*)
from bronze.crm_cust_info
group by cst_marital_status

-- Product info table 
select prd_id,count(*) 
from silver.crm_prd_info
group by prd_id
having count(*)>1 or prd_id is null;


select prd_nm
from silver.crm_prd_info
where prd_nm!=TRIM(prd_nm);

select prd_cost,count(*) -- check for null or negative number
from silver.crm_prd_info
where prd_cost<0 or prd_cost is null
group by prd_cost;

select prd_line,count(*)
from silver.crm_prd_info
group by prd_line;

SELECT  prd_end_dt,count(*)
from bronze.crm_prd_info
where prd_end_dt is null
group by prd_end_dt;

select prd_id,
prd_key,
prd_start_dt,prd_end_dt,
LEAD(prd_start_dt) over(partition by prd_key order by prd_start_dt) as prd_end_dt2
from bronze.crm_prd_info
----------------------------------------------------------
select top(100)* from bronze.crm_sales_details;
select top(100)* from bronze.crm_cust_info

select sls_ord_num,count(*) 
from silver.crm_sales_details
group by sls_ord_num
having count(*)>1 or sls_ord_num is null;

select sls_prd_key,count(*) 
from silver.crm_sales_details
group by sls_prd_key
having count(*)>1 or sls_prd_key is null;

select sls_cust_id
from bronze.crm_sales_details
where sls_cust_id is NULL

select  sls_order_dt,TRY_CAST(sls_order_dt as DATETIME) 
from bronze.crm_sales_details
where TRY_CAST(sls_order_dt as DATETIME) IS NULL
and  sls_order_dt is not null

select nullif(sls_order_dt,0)sls_order_dt 
from bronze.crm_sales_details
where sls_order_dt = 0 or len(sls_order_dt) !=8

select 
	sls_sales,
	case when sls_sales<0 then 0
	else sls_sales end as n
from bronze.crm_sales_details
where sls_sales is null or sls_sales <0

select *
from bronze.crm_sales_details
where sls_order_dt>sls_due_dt or sls_order_dt > sls_ship_dt or sls_due_dt<sls_ship_dt

select
sls_sales as old_sales,sls_quantity,sls_price as old_price,
case 
	when sls_sales is null or sls_sales<0 
		or sls_sales != abs(sls_price*sls_quantity) then abs(sls_price*sls_quantity)
	else sls_sales
	end as sls_sales,
case 
	when sls_price <=0 or sls_price is null then cast(abs(sls_sales/sls_quantity) as int)
	else sls_price
	end as sls_price
from bronze.crm_sales_details
where sls_sales != sls_price*sls_quantity
or sls_sales <=0 or sls_quantity <=0 or sls_price <=0
or sls_sales is null or sls_quantity is null or sls_price is null

----------------------------------------------------------
select top(100)* from bronze.erp_cust_az12;

Select cid,SUBSTRING(cid,4,len(cid)) 
from bronze.erp_cust_az12
where cid like 'NAS%'


Select  BDATE
from bronze.erp_cust_az12
where BDATE >GETDATE() or BDATE < '1920-01-01'

select  GEN,
	case when GEN = 'F' then 'Female'
	when GEN = 'M' then  'Male'
	when GEN = ' ' or GEN is null then 'n/a'
	else GEN end as GEN1
from bronze.erp_cust_az12
--------------------------------------------------

select distinct CID,
REPLACE(cid,'-','')cid3
from bronze.erp_loc_a101


select distinct CNTRY,
	CASE WHEN TRIM(CNTRY) is NULL or TRIM(CNTRY) = '' THEN 'n/a'
	WHEN TRIM(CNTRY) = 'DE' then 'Germany'
	WHEN TRIM(CNTRY) = 'US' or TRIM(CNTRY) = 'USA' THen 'United States'
	ELSE CNTRY
	END AS CNTRY
from bronze.erp_loc_a101

------------------------------------------------

select ID
from bronze.erp_px_cat_g1v2
where ID is null or LEN(ID)!=5

select distinct CAT
from bronze.erp_px_cat_g1v2

