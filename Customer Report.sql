/*
========================================================================================|
Customer Report:																	 	|	
========================================================================================|
Purpose: This report consolidates the key customer metrics and behaviours			 	|
																						|
Highlights:																				|
	1. Gathers essential fields such as names, ages and transaction details.			|
    2. Segments customers into categories and age groups								|
    3. Aggregates customer level metrics												|
		- total orders																	|
        - total sales																	|
		- total quantity purchased														|
        - total products																|
        - lifespan (in months)															|
	4. Calculates valuable KPIs:														|
		- recency (months since last order)												|
        - average order value															|
        - average monthly spend															|
========================================================================================|
*/
CREATE VIEW customers_report AS
WITH base_query AS (
-- Retrieves important columns from the table
SELECT 
	s.order_number,
    s.product_key,
    s.order_date,
    s.sales_amount,
    s.quantity,
    c.customer_key,
    c.customer_number,
    CONCAT(c.first_name, c.last_name) AS customer_name,
    TIMESTAMPDIFF(YEAR, c.birthdate, CURDATE()) AS customer_age
FROM sales s JOIN customer c USING (customer_key)
),
customer_aggregation AS (
-- Customer Aggregations: Summarises key metrics at customer level
SELECT
	customer_key,
    customer_number,
    customer_name,
    customer_age,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) AS last_order_date,
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY customer_key, customer_number, customer_name, customer_age
)

SELECT
	customer_key,
    customer_number,
    customer_name,
    customer_age,
    CASE
		WHEN customer_age < 20 THEN "Under 20"
        WHEN customer_age BETWEEN 20 AND 29 THEN "20-29"
        WHEN customer_age BETWEEN 30 AND 39 THEN "30-39"
        WHEN customer_age BETWEEN 40 AND 49 THEN "40-49"
        WHEN customer_age BETWEEN 50 AND 59 THEN "50-59"
        ELSE "50 and above"
	END AS age_group,
        CASE
		WHEN lifespan>=12 AND total_sales > 5000 THEN "VIP"
        WHEN lifespan>=12 AND total_sales <= 5000 THEN "REGULAR"
        ELSE "NEW"
	END AS customer_category,
    TIMESTAMPDIFF(MONTH, last_order_date, CURDATE()) AS recency,
    -- Average Order Value
    CASE
		WHEN total_orders=0 THEN 0
        ELSE total_sales/total_orders 
	END AS average_order_value,
    -- Average Monthly Spend
    CASE
		WHEN lifespan=0 THEN total_sales
        ELSE total_sales/lifespan
	END AS average_monthly_spend
FROM customer_aggregation
    
    