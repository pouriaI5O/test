
{{ config(materialized='view') }}
SELECT
order_purchase_timestamp,
    order_id,
    payment_value
FROM
  {{ source('public','olist_order_payments') }}
 