 
 
 
 {{ config(materialized='view') }} SELECT
 order_id,     
 customer_id,     
order_purchase_timestamp 
 FROM   
{{ source('public','olist_orders') }}