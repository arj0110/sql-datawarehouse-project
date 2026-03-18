📦 DIM_PRODUCTS

Purpose: Provides information about products and their attributes used for sales analysis.

Columns

| Column Name        | Data Type     | Description                                                                      |
| ------------------ | ------------- | -------------------------------------------------------------------------------- |
| product_key        | INT           | Surrogate key uniquely identifying each product record in the product dimension. |
| product_id         | INT           | Unique identifier assigned to the product in the source CRM system.              |
| product_number     | NVARCHAR(50)  | Business product code used across systems for tracking products.                 |
| product_name       | NVARCHAR(100) | Descriptive name of the product.                                                 |
| category_id        | NVARCHAR(50)  | Identifier representing the product category.                                    |
| category           | NVARCHAR(50)  | High-level product classification (e.g., Bikes, Components).                     |
| subcategory        | NVARCHAR(50)  | Detailed classification of the product within a category.                        |
| maintenance        | NVARCHAR(50)  | Indicates whether the product requires maintenance.                              |
| product_cost       | INT           | Cost associated with the product.                                                |
| product_line       | NVARCHAR(50)  | Product line or series to which the product belongs.                             |
| product_start_date | DATE          | Date when the product became available for sale.                                 |
| product_end_date   | DATE          | Date when the product was discontinued (NULL indicates active product).          |


🧑‍💼DIM_CUSTOMERS

Purpose: Stores consolidated customer information enriched from CRM and ERP systems.

Columns

| Column Name     | Data Type    | Description                                                                 |
| --------------- | ------------ | --------------------------------------------------------------------------- |
| customer_key    | INT          | Surrogate key uniquely identifying each customer record.                    |
| customer_id     | INT          | Unique customer identifier from the CRM system.                             |
| customer_number | NVARCHAR(50) | Business customer identifier used across systems.                           |
| first_name      | NVARCHAR(50) | Customer’s first name.                                                      |
| last_name       | NVARCHAR(50) | Customer’s last name.                                                       |
| country         | NVARCHAR(50) | Country associated with the customer based on ERP location data.            |
| gender          | NVARCHAR(10) | Customer gender, prioritised from CRM and supplemented from ERP if missing. |
| marital_status  | NVARCHAR(20) | Customer marital status.                                                    |
| birthdate       | DATE         | Customer date of birth.                                                     |
| create_date     | DATETIME     | Date when the customer record was created in the CRM system.                |


💰FACT_SALES
Purpose: Contains transactional sales records used for revenue, quantity, and order analysis.

Columns

| Column Name   | Data Type    | Description                                                     |
| ------------- | ------------ | --------------------------------------------------------------- |
| order_number  | NVARCHAR(50) | Unique identifier for each sales order transaction.             |
| product_key   | INT          | Foreign key referencing the product dimension (dim_products).   |
| customer_key  | INT          | Foreign key referencing the customer dimension (dim_customers). |
| order_date    | DATE         | Date when the order was placed.                                 |
| shipping_date | DATE         | Date when the order was shipped.                                |
| due_date      | DATE         | Expected delivery date for the order.                           |
| sales         | INT          | Total sales amount for the transaction.                         |
| quantity      | INT          | Number of units sold in the transaction.                        |
| price         | INT          | Price per unit of the product.                                  |


