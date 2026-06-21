/*
=====
This script creates a new 'DataWarehouse' database after checking if it already exists.
If 'DataWarehouse' exists, it is dropped and recreated.
Additionally, the script sets up three schemas within the database:
bronze
silver
gold
=====

=====
Warning:
This script will drop the entire 'DataWarehouse' database if it exists.
All data in the database will be permanently deleted.
Proceed with caution keeping the backups in mind.
=====0
*/

use master;
go

-- Drop and recreate the 'DataWarehouse' database
if exists(select 1 from sys.databases where name = 'DataWarehouse')
begin
	alter database DataWarehouse set single_user with rollback immediate;
	drop database DataWarehouse;
end;
go


create database DataWarehouse;
go


use DataWarehouse;
go


-- Creating Schemas
create schema bronze;
go
create schema silver;
go
create schema gold;
go
