-- Calculate the total revenue at the order purchase date grain
---This query creates a materialized view called "base_order_payments" that calculates the total payment value 
---for each order by summing the "payment_value" column in the "olist_order_payments" table. 
---The result is grouped by the order ID. This view helps in analyzing payment information related to orders.
{{ config(materialized='view') }}
WITH total_revenue AS (
  SELECT DATE_TRUNC('day', o.order_purchase_timestamp) AS order_purchase_date,
         SUM(op.payment_value) AS revenue_usd
FROM {{ ref('base_orders')}} o
  JOIN {{ ref('base_order_payments')}} op ON o.order_id = op.order_id
  GROUP BY 1
)
SELECT *
FROM total_revenue