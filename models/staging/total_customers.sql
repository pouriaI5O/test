-- Calculate the total number of unique customers making orders at the order purchase date grain
{{ config(materialized='view') }}
WITH total_customers AS (
  SELECT DATE_TRUNC('day', order_purchase_timestamp) AS order_purchase_date,
         COUNT(DISTINCT customer_id) AS customers_making_orders_count
 FROM {{ ref('base_orders')}}
  GROUP BY 1
)
SELECT *
FROM total_customers
