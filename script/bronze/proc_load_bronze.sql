/*
Full loading the tables from the source in the tables of 'DataWarehouse' database.
First truncating the tables and then bulk inserting the values from the source folders
*/

create or alter procedure bronze.load_bronze as
begin
	
	declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;

	set @batch_start_time = getdate();
	begin try
		print('=================================================');
		print('Loading Bronze Layer');
		print('=================================================');

		print('-------------------------------------------------');
		print('Loading crm tables');
		print('-------------------------------------------------');
		

		----
		set @start_time = getdate();
		print ('>> truncate table - bronze.crm_cust_info')
		truncate table bronze.crm_cust_info;
	
		print ('>> bulk insert - bronze.crm_cust_info')
		bulk insert	bronze.crm_cust_info
		from 'C:\Users\reach\OneDrive\Data Engineer Path\DataWithBaraa\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		print('>> Load Duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds');
		print('----------------------------------');
		----


		----
		set @start_time = getdate();
		print('>> truncate table - bronze.crm_prd_info');
		truncate table bronze.crm_prd_info;

		print('>> bulk insert - bronze.crm_prd_info');
		bulk insert	bronze.crm_prd_info
		from 'C:\Users\reach\OneDrive\Data Engineer Path\DataWithBaraa\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		print('>> Load Duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds');
		print('----------------------------------');
		----


		----
		set @start_time = getdate();
		print('>> truncate table - bronze.crm_sales_details');
		truncate table bronze.crm_sales_details;

		print('>> bulk insert - bronze.crm_sales_details');
		bulk insert	bronze.crm_sales_details
		from 'C:\Users\reach\OneDrive\Data Engineer Path\DataWithBaraa\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		print('>> Load Duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds');
		print('----------------------------------');
		----


		print('-------------------------------------------------');
		print('Loading erp tables');
		print('-------------------------------------------------');
	
		
		----
		set @start_time = getdate();
		print('>> truncate table - bronze.erp_cust_az12');
		truncate table bronze.erp_cust_az12;

		print('>> bulk insert - bronze.erp_cust_az12');
		bulk insert	bronze.erp_cust_az12
		from 'C:\Users\reach\OneDrive\Data Engineer Path\DataWithBaraa\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		print('>> Load Duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds');
		print('----------------------------------');
		----


		----
		set @start_time = getdate();
		print('>> truncate table - bronze.erp_loc_a101');
		truncate table bronze.erp_loc_a101;

		print('>> bulk insert - bronze.erp_loc_a101');
		bulk insert	bronze.erp_loc_a101
		from 'C:\Users\reach\OneDrive\Data Engineer Path\DataWithBaraa\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		print('>> Load Duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds');
		print('----------------------------------');
		----


		----
		set @start_time = getdate();
		print('>> truncate table - bronze.erp_px_cat_g1v2');
		truncate table bronze.erp_px_cat_g1v2;

		print('>> bulk insert - bronze.erp_px_cat_g1v2');
		bulk insert	bronze.erp_px_cat_g1v2
		from 'C:\Users\reach\OneDrive\Data Engineer Path\DataWithBaraa\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		print('>> Load Duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds');
		print('----------------------------------');
		----


	end try
	begin catch
		print('=================================================');
		print('An error occurred while loading the Bronze layer');
		print('Error message: ' + error_message());
		print('Error number: ' + cast(error_number() as nvarchar));
		print('Error state: ' + cast(error_state() as nvarchar));
		print('=================================================');
	end catch
	set @batch_end_time = getdate();
	print('>> Batch Load Duration ' + cast(datediff(second, @batch_start_time, @batch_end_time) as nvarchar) + ' seconds');
end;
