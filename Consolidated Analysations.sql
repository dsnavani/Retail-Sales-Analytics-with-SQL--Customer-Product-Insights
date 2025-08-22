
-- Create Schema
CREATE SCHEMA data_analytics_sql;

 -- Creating Tables
 CREATE TABLE customer(
	customer_key INT,
    customer_id INT,
    customer_number VARCHAR(50),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    country VARCHAR(50),
    marital_status VARCHAR(50),
    gender VARCHAR(50),
    birthdate DATE,
    create_date DATE
);

CREATE TABLE products(
	product_key INT,
    product_id INT,
    product_number VARCHAR(50),
    product_name VARCHAR(50),
    category_id VARCHAR(50),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    maintenance VARCHAR(50),
    cost INT,
    product_line VARCHAR(50),
    start_date DATE
);

CREATE TABLE sales(
	order_number VARCHAR(50),
    product_key INT,
    customer_key INT,
    order_date DATE,
    shipping_date DATE,
    due_date DATE,
    sales_amount INT,
    quantity TINYINT,
    price INT
);

-- Sample Data
SELECT * FROM customer LIMIT 10;
SELECT * FROM products LIMIT 10;
SELECT * FROM sales LIMIT 10;

-- CHANGES OVER TIME ANALYSIS
-- Analyse the sales performance over time
-- 1. Yearly Sales Performance
SELECT 
	YEAR(order_date) AS order_year, 
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

-- 2. Monthly sales performance to identify seasonality
SELECT 
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date);

-- 3. Monthly sales performance on each year
SELECT 
	YEAR(order_date) AS order_year, 
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY YEAR(order_date),MONTH(order_date);

-- CUMULATIVE ANALYSIS
-- Calculate the total sales per month and the running total of sales over time
SELECT 
	order_month,
    total_sales,
    SUM(total_sales) OVER (PARTITION BY YEAR(order_month) ORDER BY order_month) AS running_total,
    AVG(average) OVER (PARTITION BY YEAR(order_month) ORDER BY order_month) AS moving_average
FROM
(SELECT 
	DATE_SUB(order_date, INTERVAL DAY(order_date) - 1 DAY) AS order_month, 
    SUM(sales_amount) AS total_sales, AVG(sales_amount) AS average
FROM sales
GROUP BY DATE_SUB(order_date, INTERVAL DAY(order_date) - 1 DAY)
ORDER BY DATE_SUB(order_date, INTERVAL DAY(order_date) - 1 DAY)) t;

-- PERFORMANCE ANALYSIS
-- Analyze the yearly performance of products by comparing each products sales to both it's average sales performance and previous year sales performance

WITH product_sales_details AS (
SELECT 
	p.product_name,
    YEAR(s.order_date) AS order_year,
    SUM(s.sales_amount) AS total_sales
FROM sales s JOIN products p USING (product_key)
GROUP BY p.product_name, YEAR(s.order_date))
SELECT 
	order_year,
    product_name,
    total_sales,
    AVG(total_sales) OVER(PARTITION BY product_name) AS avg_sales,
	(total_sales - AVG(total_sales) OVER(PARTITION BY product_name)) AS avg_diff,
    LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS pre_yr_sales,
    (total_sales - LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year)) AS pre_yr_diff
FROM product_sales_details
ORDER BY product_name;

-- PART TO WHOLE ANALYSIS - Analyze how an individual part is performing compared to the overall, alowing us to understand which category has the greatest impact on the business
-- Which category contribute the most to overall sales
WITH cat_sale AS(
SELECT 
	category, SUM(sales_amount) sales_amount
FROM sales JOIN products USING (product_key)
GROUP BY category)
SELECT 
	category, sales_amount, 
    SUM(sales_amount) OVER() total_sales, ROUND((sales_amount/(SUM(sales_amount) OVER())),2)*100 total_percentage
FROM cat_sale
ORDER BY sales_amount DESC;

-- DATA SEGMENTATION - Group the data based on a specific range
-- Segment products in cost ranges and count how many products fall into each segment

WITH data_segmentation AS (
SELECT 
	product_key, 
    product_name, 
    cost,
    CASE 
		WHEN cost<100 THEN "Below 100"
        WHEN cost BETWEEN 100 AND 500 THEN "100-200"
        WHEN cost BETWEEN 500 AND 1000 THEN "500-1000"
        ELSE "Above 1000"
	END cost_range
FROM products)

SELECT 
	cost_range,
    COUNT(cost_range) AS count
FROM data_segmentation
GROUP BY cost_range
ORDER BY count DESC;

-- Group customers in three segments based on their spending behaviour
-- VIP: At least 12 months of history and spending more than 5000
-- REGULAR: At least 12 months of history and spending less than 5000
-- NEW: less than 12 months of history
WITH customer_history AS
(
SELECT
	c.customer_key, 
    SUM(s.sales_amount) total_spending, 
    TIMESTAMPDIFF(MONTH, MIN(s.order_date), MAX(s.order_date)) lifespan
FROM sales s JOIN customer c USING (customer_key)
GROUP BY c.customer_key
)
SELECT 
	customer_category,
    COUNT(customer_key) count
FROM (
SELECT 
	customer_key,
    total_spending,
    lifespan,
    CASE
		WHEN lifespan>=12 AND total_spending > 5000 THEN "VIP"
        WHEN lifespan>=12 AND total_spending <= 5000 THEN "REGULAR"
        ELSE "NEW"
	END AS customer_category
FROM customer_history ) t
GROUP BY customer_category
ORDER BY count DESC

