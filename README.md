Project Summary:
This project involved utilizing DBT (Data Build Tool) to analyze and transform a sample dataset from the Olist order management system. The goal was to create DBT models and lineage that generate various metrics at the order purchase date grain, including total orders, total customers making orders, total revenue, average revenue per order, top 3 product categories by revenue, and the percentage of day's revenue associated with each of the top 3 product categories. Additionally, features for data cleaning, unit testing, and exception reporting for faulty data were implemented.

Step-by-Step Process:

Data Access:

The dataset was accessed from the Mode Analytics platform.
Tables were located under the "brooklyndata.olist_" schema.
Data Preparation:

The data was exported from Mode Analytics.
The exported data was stored in a suitable database compatible with DBT (e.g., Snowflake or a local database).
DBT Models:
a. Total Orders:

This model calculated the total number of orders at the order purchase date grain.
It used aggregation to count the distinct order IDs.
b. Total Customers Making Orders:

This model determined the total number of unique customers who made orders at the order purchase date grain.
It leveraged unique customer IDs to count the customers.
c. Total Revenue:

This model calculated the total revenue generated at the order purchase date grain.
It utilized aggregation to sum the payment values.
d. Average Revenue per Order:

This model computed the average revenue per order at the order purchase date grain.
It divided the total revenue by the total number of orders.
e. Top 3 Product Categories by Revenue:

This model identified the top 3 product categories that generated the highest revenue for each order purchase date.
It considered the revenue associated with each product category and selected the top 3.
f. Percent of Day's Revenue by Top 3 Product Categories:

This model calculated the percentage of the day's revenue associated with each of the top 3 product categories.
It determined the revenue contribution of each category and expressed it as a percentage of the total revenue.
Data Cleaning:

Data cleaning techniques were implemented to handle faulty or inconsistent data points.
These techniques ensured data accuracy and improved the quality of the metrics.
Unit Testing:

Unit tests were created for each DBT model to validate the accuracy and reliability of the derived metrics.
The tests checked for null values, data completeness, and verified the expected outputs against the actual results.
Exception Reporting:

An exception report was generated to highlight any faulty data that deviated from expected patterns.
This report helped identify and resolve data quality issues, ensuring the reliability of the metrics.
Final Table:

The metrics from the DBT models were combined into a final table.
The table included columns such as order_purchase_date, orders_count, customers_making_orders_count, revenue_usd, average_revenue_per_order_usd, top_3_product_categories_by_revenue, and top_3_product_categories_revenue_percentage.
This table provided a comprehensive view of the order management system's performance.
Documentation and Reporting:

Detailed documentation was provided, including code comments explaining the logic of each query and how the metrics were derived.
A report summarizing the project was prepared, highlighting the steps taken, the implemented models, the testing approach, and any assumptions or clarifications requested from the client.
Conclusion:
By leveraging DBT, this project successfully analyzed the Olist order management dataset and generated key metrics at the order purchase date grain. The implementation of data cleaning, unit testing, and exception reporting ensured the accuracy and reliability of the metrics. The final table provided valuable insights into the client's order management system, facilitating decision-making and supporting the migration to the new system.
