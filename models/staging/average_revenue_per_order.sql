-- Calculate the average revenue per order at the order purchase date grain
{{ config(materialized='view') }}
WITH average_revenue_per_order AS (
  SELECT DATE_TRUNC('day', o.order_purchase_timestamp) AS order_purchase_date,
         AVG(op.payment_value) AS average_revenue_per_order_usd
  FROM {{ ref('base_orders')}} o
  JOIN {{ ref('base_order_payments')}}op ON o.order_id = op.order_id
  GROUP BY 1
)
SELECT *
FROM average_revenue_per_order

