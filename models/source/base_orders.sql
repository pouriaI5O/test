 {{ config(materialized='view') }} SELECT
 order_id,     
 customer_id,     
 CAST(order_purchase_timestamp AS DATE) AS order_purchase_date 
 FROM   
{{ source('public','olist_orders') }}