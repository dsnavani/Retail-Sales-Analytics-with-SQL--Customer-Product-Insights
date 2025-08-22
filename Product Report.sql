/*
====================================================================================================|
Product Report:																		 				|	
====================================================================================================|
Purpose: This report consolidates the key product metrics and behaviours			 				|
																									|
Highlights:																							|
	1. Gathers essential fields such as product name, category, sub category and cost.				|
    2. Segments products by revenue to identify high performers, mid performers and low performers	|
    3. Aggregates product level metrics																|
		- total orders																				|
        - total sales																				|
		- total quantity sold																		|
        - total customers (unique)																	|
        - lifespan (in months)																		|
	4. Calculates valuable KPIs:																	|
		- recency (months since last sales)															|
        - average order revenue																		|
        - average monthly revenue																	|
====================================================================================================|
*/

-- CREATE VIEW products_report AS
WITH base_query AS (
-- Retrieves important columns from table
SELECT 
	p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost,
    s.customer_key,
    s.order_number,
    s.order_date,
    s.sales_amount,
    s.quantity
FROM products p JOIN sales s USING (product_key)
WHERE s.order_date IS NOT NULL
),
product_aggregations AS(
-- Summarises key metrics at the product level
SELECT
	product_key, product_name, category, subcategory, cost,
	TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
	MAX(order_date) AS last_order_date,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	CASE
		WHEN SUM(quantity)=0 THEN 0
		ELSE AVG(sales_amount/quantity)
	END AS avg_selling_price
FROM base_query
GROUP BY product_key, product_name, category, subcategory, cost)


SELECT 
	product_key, product_name, category, subcategory, cost, lifespan, last_order_date, total_orders, total_customers, total_sales, total_quantity,
    TIMESTAMPDIFF(MONTH, last_order_date, CURDATE()) AS recency,
    -- Average Order Revenue
    CASE
		WHEN total_orders=0 THEN 0
        ELSE total_sales/total_orders
	END AS average_order_revenue,
    -- Average Monthly Revenue
    CASE
		WHEN lifespan=0 THEN total_sales
        ELSE total_sales/lifespan
	END AS average_monthly_revenue
FROM product_aggregations
