# sql-datawarehouse-project
Building a modern Data warehouse using SQL Server, which includes  ETL process, data modelling and analysis.

This project demonstrates an end-to-end Data Warehouse and Analytics pipeline built using Microsoft SQL Server. The architecture follows the Medallion framework (Bronze → Silver → Gold) to progressively transform raw data into clean, business-ready datasets for analytics and reporting.

Data from ERP and CRM systems (CSV files) is ingested through an ETL process into the Bronze layer (raw data), cleaned and standardised in the Silver layer, and finally modelled into analytics-ready tables using a star schema in the Gold layer.

The final datasets are designed for business intelligence tools like Power BI and advanced analytics.

Key Highlights:

SQL Server-based Data Warehouse implementation
ETL pipeline for batch data ingestion
Medallion architecture (Bronze, Silver, Gold layers)
Data cleansing, standardisation, and transformation
Star schema for analytical queries
Business-ready datasets for BI and reporting
