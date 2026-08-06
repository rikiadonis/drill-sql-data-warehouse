/*
=================================================================================
Create Database and Schemas
================================================================================-
Script Purpose:
  This script creates a new databases named 'DrillDataWarehouse' after checking if it already exists.
  Id database exists, it is dropped and recreated. Additionaly, the scripts sets up three schemas
within databse: 'bronze', 'silver', and 'gold'.

WARNING:
  Running this script will drop the entire 'DrillDataWarehouse' database if it exists.
  All data in database will be pernamently deleted. Proceed with caution 
  and ensure you have proper backups before running this scripts.
*/

USE master;
GO

-- Drop and reaceated the 'DrillDataWarehouse'
IF EXISTS (SELECT 1 FROM sys.database WHERE name = 'DrillDataWarehouse')
BEGIN
  ALTER DATABASE DrillDataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE DrillDataWarehouse;
END;
GO

-- Create the 'DrillDataWarehouse' database\
CREATE DATABASE DrillDataWarehouse;
GO

USE DrillDataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
