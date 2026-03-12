-- Switch to the master database to create a new database
USE master;

-- Create the main database for the Data Warehouse project
CREATE DATABASE Datawarehouse;

-- Switch context to the newly created Datawarehouse database
USE Datawarehouse;

-- Create schema for the Bronze layer
-- This layer stores raw data exactly as received from source systems (ERP, CRM)
CREATE SCHEMA bronze;

-- Create schema for the Silver layer
-- This layer contains cleaned, standardized, and transformed data
CREATE SCHEMA silver;

-- Create schema for the Gold layer
-- This layer contains business-ready data models (facts, dimensions, aggregated tables)
-- Used by BI tools like Power BI and for analytics
CREATE SCHEMA gold;
