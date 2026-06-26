/*
=========================================================================================
DDL Script: Create Gold View
=========================================================================================

Script Purpose:
	This script creates views for the Gold layer in the Data Warehouse.
	The gold layer represents the final dimension and fact tables in Star Schema.
Usage:
	These views can be queried directly for analysis and reporting purpose.
*/


create or alter view gold.dim_customers as (
select
	row_number() over(order by ci.cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	ci.cst_marital_status as marital_status,
	case
		when ci.cst_gndr = 'NA' then ca.gen
		else ci.cst_gndr
	end as gender,
	ca.bdate as birth_date,
	la.cntry as country,
	ci.cst_create_date as create_date
from silver.crm_cust_info as ci
left join silver.erp_cust_az12 as ca
on ci.cst_key = ca.cid
left join silver.erp_loc_a101 as la
on ci.cst_key = la.cid
);


create or alter view gold.dim_products as (
select
	row_number() over(order by pn.prd_start_dt, pn.prd_key) as product_key,
	pn.prd_id as product_id,
	pn.sls_prd_key as product_number,
	pn.prd_nm as product_name,
	pn.prd_cost as product_cost,
	pn.cat_id as category_id,
	pc.cat as category,
	pc.subcat as subcategory,
		pn.prd_line as product_line,
	pc.maintenance as maintenance,
	pn.prd_start_dt as start_date
from silver.crm_prd_info as pn
left join silver.erp_px_cat_g1v2 as pc on
pn.cat_id = pc.id
where
	pn.prd_end_dt is null -- only continuing products
);



create or alter view gold.fact_sales as (
select
	top 100
	sd.sls_ord_num as order_number,
	pr .product_key,
	cu.customer_key,
	sd.sls_order_dt as order_date,
	sd.sls_ship_dt as ship_date,
	sd.sls_due_dt as due_date,
	sd.sls_sales as sales_amount,
	sd.sls_quantity as quantity,
	sd.sls_price as price
from silver.crm_sales_details as sd
left join gold.dim_products as pr
on sd.sls_prd_key = pr.product_number
left join gold.dim_customers as cu
on sd.sls_cust_id = cu.customer_id
);
