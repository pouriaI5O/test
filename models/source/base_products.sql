---This query creates a materialized view called "base_products" that retrieves the product ID and product category name 
---from the "olist_products" table. 
---It helps in categorizing and analyzing products.
{{ config(materialized='view') }}
SELECT
    product_id,
    product_category_name
FROM
   {{ source('public','olist_products') }}