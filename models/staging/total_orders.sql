-- Calculate the total number of orders at the order purchase date grain
----This query creates a materialized view called "base_orders" that retrieves the order ID, customer ID, and 
 ----the date of purchase from the "olist_orders" table. 
 ----The CAST function is used to convert the "order_purchase_timestamp" column to a date format. 
 ----This view provides a convenient way to access basic order information.
{{ config(materialized='view') }}
WITH total_orders AS (
  SELECT DATE_TRUNC('day', order_purchase_timestamp) AS order_purchase_date,
         COUNT(DISTINCT order_id) AS orders_count
  FROM {{ ref('base_orders')}}
  GROUP BY 1
)
SELECT *
FROM total_orders