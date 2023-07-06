---This query creates a materialized view called "base_order_items" that retrieves the order ID, product ID, 
---and price from the "olist_order_items" table. 
---It provides information about the items included in each order.
{{ config(materialized='view') }}
SELECT
    order_id,
    product_id,
    price
FROM
     {{ source('public','olist_order_items') }}