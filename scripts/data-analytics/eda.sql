/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for all tables.

Table Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

-- Explore all objects in the DB
SELECT
*
FROM INFORMATION_SCHEMA.TABLES;
-------------------------------------------------------------
-- These four columns are the sample information we may look at in the TABLES table coming from the course.
--    TABLE_CATALOG, 
--    TABLE_SCHEMA, 
--    TABLE_NAME, 
--    TABLE_TYPE
-------------------------------------------------------------

  
-- Explore all columns in the DB
SELECT
*
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';
-------------------------------------------------------------
-- These four columns are the sample information we may look at in the COLUMNS table coming from the course.
--    COLUMN_NAME, 
--    DATA_TYPE, 
--    IS_NULLABLE, 
--    CHARACTER_MAXIMUM_LENGTH
-------------------------------------------------------------





/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

-- Explore all unique countries our customers come from
SELECT DISTINCT
  country
FROM gold.dim_customers;

-- Explore all product categories "the major divisions"
SELECT DISTINCT
  category
FROM gold.dim_products;

-- Explore all product categories, including the product name
SELECT DISTINCT
  category,
  subcategory,
  product_name
FROM gold.dim_products
ORDER BY 1, 2, 3;





/*
===============================================================================
Date Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- Find the date of the first and last order
-- How many years of sales are available
SELECT 
  MIN(order_date) AS first_order_date,
  MAX(order_date) AS last_order_date,
  DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_range_years
FROM gold.fact_sales;

-- Find the youngest and the oldest customer
SELECT 
  MIN(birthdate) AS oldest_birthdate,
  DATEDIFF(YEAR, MIN(birthdate), GETDATE()) as oldest_age,
  MAX(birthdate) AS youngest_birthdate,
  DATEDIFF(YEAR, MAX(birthdate), GETDATE()) as youngest_age
FROM gold.dim_customers;





/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

-- Find the Total Sales
SELECT
  SUM(sales_amount) AS total_sales
FROM gold.fact_sales

-- Find how many items are sold
SELECT 
  SUM(quantity) AS total_items
FROM gold.fact_sales

-- Find the average selling price
SELECT
  AVG(price) AS avg_selling_price
FROM gold.fact_sales

-- Find the Total number of Orders
-- One order may include multiple items
SELECT
  COUNT(order_number) AS total_orders,
  COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales

-- Find the total number of products
SELECT
  COUNT(*) AS total_products
FROM gold.dim_products

-- Find the total number of customers
SELECT
  COUNT(customer_key) AS total_customers
FROM gold.dim_customers

-- Find the total number of customers that has placed an order
SELECT 
  COUNT(DISTINCT customer_key) num_of_customers_placed_order
FROM gold.fact_sales


-- Generate a Report that shows all key metrics of the business
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Items' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Selling Price' AS measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Number of Orders' AS measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Number of Products' AS measure_name, COUNT(*) AS measure_value FROM gold.dim_products
UNION ALL
SELECT 'Total Number of Customers' AS measure_name, COUNT(DISTINCT customer_key) AS measure_value FROM gold.fact_sales;





/*
===============================================================================
Magnitude Analysis
===============================================================================
Purpose:
    - To quantify data and group results by specific columns.
    - For understanding data distribution across categories.

SQL Functions Used:
    - Aggregate Functions: SUM(), COUNT(), AVG()
    - GROUP BY, ORDER BY
===============================================================================
*/

-- Find total customers by countries
SELECT
  country,
  COUNT(*) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC

-- Find total customers by gender
SELECT
  gender,
  COUNT(*) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC

-- Find total products by category
SELECT
  category,
  COUNT(*) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC

-- What are the average costs in each category?
SELECT
  category,
  AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC

-- What is the total revenue generated for each category?
SELECT
  p.category,
  SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
     ON   f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue DESC

-- Find the total revenue generated by each customer
SELECT
  c.customer_key,
  c.first_name,
  c.last_name,
  SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
     ON   f.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC

-- What is the distribution of sold items across countries?
SELECT
  c.country,
  SUM(f.quantity) AS total_sold_items
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
     ON   f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC





/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items based on performance or other metrics.
    - To identify top/bottom performers.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/


-- Which 5 products generate the highest revenue
SELECT TOP 5
  p.product_name,
  SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
     ON   f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC


-- Using window function
SELECT
*
FROM (
	SELECT
	  p.product_name,
	  SUM(f.sales_amount) AS total_revenue,
	  RANK() OVER (ORDER BY SUM(f.sales_amount) desc) AS revenue_rank
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
	     ON   f.product_key = p.product_key
	GROUP BY p.product_name
)t 
WHERE revenue_rank <= 5


-- What are the 5 worst-performing products in terms of sales
SELECT TOP 5
  p.product_name,
  SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
     ON   f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC
