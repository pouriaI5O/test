-- Calculate the percentage of each day's revenue associated with the top 3 product categories
WITH daily_revenue AS (
  SELECT DATE_TRUNC('day', o.order_purchase_timestamp) AS order_purchase_date,
         SUM(op.payment_value) AS daily_revenue,
         false AS is_faulty
  FROM {{ ref('base_orders')}} o
  JOIN {{ ref('base_order_payments')}} op ON o.order_id = op.order_id
  GROUP BY 1
), 
top_3_product_categories_by_revenue AS (
  SELECT order_purchase_date,
         top_3_product_categories_by_revenue,
         is_faulty
  FROM {{ ref('top_3_product_categories_by_revenue')}}
),
category_revenue AS (
  SELECT DATE_TRUNC('day', o.order_purchase_timestamp) AS order_purchase_date,
         p.product_category_name,
         SUM(op.payment_value) AS category_revenue,
         false AS is_faulty
  FROM {{ ref('base_orders')}} o
  JOIN {{ ref('base_order_items')}} oi ON o.order_id = oi.order_id
  JOIN {{ ref('base_products')}} p ON oi.product_id = p.product_id
  JOIN {{ ref('base_order_payments')}} op ON o.order_id = op.order_id
  GROUP BY 1, 2
),
top_categories_revenue AS (
  SELECT t.order_purchase_date,
         t.top_3_product_categories_by_revenue,
         SUM(c.category_revenue) AS top_3_revenue,
         false AS is_faulty
  FROM top_3_product_categories_by_revenue t
  JOIN category_revenue c ON t.order_purchase_date = c.order_purchase_date
                          AND SPLIT_PART(t.top_3_product_categories_by_revenue, ', ', 1) = c.product_category_name
                          OR SPLIT_PART(t.top_3_product_categories_by_revenue, ', ', 2) = c.product_category_name
                          OR SPLIT_PART(t.top_3_product_categories_by_revenue, ', ', 3) = c.product_category_name
  GROUP BY 1, 2
)
SELECT t.order_purchase_date,
       LISTAGG(ROUND(c.category_revenue * 100 / t.top_3_revenue, 2)::varchar, ', ') WITHIN GROUP (ORDER BY c.product_category_name) AS top_3_product_categories_revenue_percentage,
       t.is_faulty
FROM top_categories_revenue t
JOIN category_revenue c ON t.order_purchase_date = c.order_purchase_date
                        AND (SPLIT_PART(t.top_3_product_categories_by_revenue, ', ', 1) = c.product_category_name
                             OR SPLIT_PART(t.top_3_product_categories_by_revenue, ', ', 2) = c.product_category_name
                             OR SPLIT_PART(t.top_3_product_categories_by_revenue, ', ', 3) = c.product_category_name)
GROUP BY 1, t.top_3_product_categories_by_revenue, t.top_3_revenue, t.is_faulty
