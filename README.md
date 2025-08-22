# Retail Sales Analytics with SQL: Customer & Product Insights  

## 📌 Project Overview  
This project demonstrates end-to-end **retail sales analytics using SQL**.  
The goal is to uncover **customer behavior patterns, product performance, and sales trends** that can help businesses make data-driven decisions.  

Key areas covered:  
- Sales performance analysis over time (yearly, monthly, cumulative).  
- Customer segmentation based on age, recency, spending, and loyalty.  
- Product performance benchmarking (revenue, orders, recency, selling price).  
- Category-level contribution and part-to-whole analysis.  
- Data segmentation for actionable business insights.  

---

## 🗂️ Files in this Repository  
1. **Consolidated Analysations.sql**  
   - Creates schema & tables (`customer`, `products`, `sales`).  
   - Performs sales trend analysis, category contribution, customer & product segmentation.  

2. **Customer Report.sql**  
   - Creates a view `customers_report`.  
   - Aggregates **customer-level KPIs**: total orders, total sales, recency, average order value, monthly spend.  
   - Segments customers by **age groups** and **spending behavior** (VIP, Regular, New).  

3. **Product Report.sql**  
   - Creates a view `products_report`.  
   - Aggregates **product-level KPIs**: sales, orders, customers, revenue, lifespan, recency.  
   - Segments products into **high, mid, low performers**.  

---

## 🛠️ Tech Stack  
- **SQL** (MySQL syntax)  
- **Data Modeling** (Customer, Product, Sales schema)  
- **Window Functions** (`LAG`, `AVG OVER`, `SUM OVER`)  
- **CTEs** for modular, reusable queries  

---

## 📊 Key Insights You Can Generate  
- Seasonal trends in sales performance (monthly/annual).  
- Identification of **VIP customers** and **high-value products**.  
- Category contributions to overall sales.  
- Customer recency and churn risk analysis.  
- Average monthly spend and order value insights.  

---
