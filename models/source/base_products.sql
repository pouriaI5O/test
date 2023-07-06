-- base_products.sql
{{ config(materialized='view') }}
SELECT
    product_id,
    product_category_name
FROM
   {{ source('public',' olist_products') }}