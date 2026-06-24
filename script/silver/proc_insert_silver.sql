/*
Full Inserting the tables from the bronze layer in the silver layer.
First truncating the tables and then inserting the values from the bronze layer.
*/

create or alter procedure silver.Insert_silver as
begin
	
	declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;

	set @batch_start_time = getdate();
	begin try
		print('=================================================');
		print('Creating Silver Layer');
		print('=================================================');

		print('-------------------------------------------------');
		print('Inserting crm tables');
		print('-------------------------------------------------');
		

		----
		set @start_time = getdate();
		print ('>> truncate table - silver.crm_cust_info');
		truncate table silver.crm_cust_info;
	
		print ('>> insert - silver.crm_cust_info');
		;with cte_cst_id_rank as(
			select
				*,
				row_number() over(partition by cst_id order by cst_create_date desc) as cst_rank
			from bronze.crm_cust_info
			where
		cst_id is not null
		)

		insert into silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		select
			cst_id,
			cst_key,
			trim(cst_firstname) as cst_firstname,
			trim(cst_lastname) as cst_lastname,
			case trim(cst_marital_status)
				when 'M' then 'Married'
				when 'S' then 'Single'
				else 'NA'
			end as cst_marital_status,
			case trim(cst_gndr)
				when 'M' then 'Male'
				when 'F' then 'Female'
				else 'NA'
			end as cst_gndr,
			cst_create_date
		from cte_cst_id_rank
		where cst_rank = 1;
		set @end_time = getdate();
		print('>> Insert Duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds');
		print('----------------------------------');
		----


		----
		set @start_time = getdate();
		print('>> truncate table - silver.crm_prd_info');
		truncate table silver.crm_prd_info;

		print('>> insert - silver.crm_prd_info');
		insert into silver.crm_prd_info (
			prd_id,
			prd_key,
			cat_id,
			sls_prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		select
			prd_id,
			prd_key,
			replace(substring(prd_key, 1, 5), '-', '_') as cat_id,
			substring(prd_key, 7, len(prd_key)) as sls_prd_key,
			prd_nm,
			prd_cost,
			case trim(upper(prd_line))
				when 'M' then 'Mountain'
				when 'R' then 'Road'
				when 'S' then 'Other Sales'
				when 'T' then 'Touring'
				else 'NA'
			end as prd_line,
			prd_start_dt,
			lead(dateadd(day, -1, prd_start_dt), 1) over(partition by prd_key order by prd_start_dt desc) as prd_end_dt
		from bronze.crm_prd_info;
		set @end_time = getdate();
		print('>> Insert Duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds');
		print('----------------------------------');
		----


		----
		set @start_time = getdate();
		print('>> truncate table - silver.crm_sales_details');
		truncate table silver.crm_sales_details;

		print('>> insert - silver.crm_sales_details');
		insert into silver.crm_sales_details (
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
		select
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			case
				when len(sls_order_dt) != 8 or sls_order_dt <= 0 then NULL
				else try_convert(date, cast(sls_order_dt as varchar(8)), 112)
			end as sls_order_dt,
			case
				when len(sls_ship_dt) != 8 or sls_ship_dt <= 0 then NULL
				else try_convert(date, cast(sls_ship_dt as varchar(8)), 112)
			end as sls_ship_dt,
			case
				when len(sls_due_dt) != 8 or sls_due_dt <= 0 then NULL
				else try_convert(date, cast(sls_due_dt as varchar(8)), 112)
			end as sls_due_dt,
			case
				when sls_sales is null or sls_sales <= 0 or sls_sales != (sls_quantity * abs(sls_price))
				then (sls_quantity * abs(sls_price))
				else sls_sales
			end as sls_sales,
			sls_quantity,
			case
				when sls_price is null or sls_price <= 0
				then (sls_sales / nullif(sls_quantity, 0))
				else sls_price
			end as sls_price
		from bronze.crm_sales_details;
		set @end_time = getdate();
		print('>> Insert Duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds');
		print('----------------------------------');
		----


		print('-------------------------------------------------');
		print('Inserting erp tables');
		print('-------------------------------------------------');
	
		
		----
		set @start_time = getdate();
		print('>> truncate table - silver.erp_cust_az12');
		truncate table silver.erp_cust_az12;

		print('>> insert - silver.erp_cust_az12');
		insert into silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		select
			trim(case
				when cid like 'NAS%' then substring(cid, 4, len(cid))
				else cid
			end) as cid,
			case
				when bdate > getdate() then NULL
				else bdate
			end as bdate,
			case upper(trim(gen))
				when 'F' then 'Female'
				when '' then Null
				when 'M' then 'Male'
				else trim(gen)
			end as gen
		from bronze.erp_cust_az12;
		set @end_time = getdate();
		print('>> Insert Duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds');
		print('----------------------------------');
		----


		----
		set @start_time = getdate();
		print('>> truncate table - silver.erp_loc_a101');
		truncate table silver.erp_loc_a101;

		print('>> insert - silver.erp_loc_a101');
		insert into silver.erp_loc_a101 (
			cid,
			cntry
		)
		select
			replace(cid, '-', '') as cid,
			case 
				when trim(cntry) = '' then Null
				when trim(cntry) = 'DE' then 'Germany'
				when trim(cntry) in ('USA', 'US') then 'United States'
				else trim(cntry)
			end as cntry
		from bronze.erp_loc_a101;
		set @end_time = getdate();
		print('>> Insert Duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds');
		print('----------------------------------');
		----


		----
		set @start_time = getdate();
		print('>> truncate table - silver.erp_px_cat_g1v2');
		truncate table silver.erp_px_cat_g1v2;

		print('>> insert - silver.erp_px_cat_g1v2');
		insert into silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)
		select
			id,
			cat,
			subcat,
			maintenance
		from bronze.erp_px_cat_g1v2;
		set @end_time = getdate();
		print('>> Insert Duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds');
		print('----------------------------------');
		----


	end try
	begin catch
		print('=================================================');
		print('An error occurred while Inserting the Silver layer');
		print('Error message: ' + error_message());
		print('Error number: ' + cast(error_number() as nvarchar));
		print('Error state: ' + cast(error_state() as nvarchar));
		print('=================================================');
	end catch
	set @batch_end_time = getdate();
	print('>> Batch Insert Duration ' + cast(datediff(second, @batch_start_time, @batch_end_time) as nvarchar) + ' seconds');
end;
