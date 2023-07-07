  -- Calculate the top 3 product categories by revenue for each order purchase date
WITH category_revenue AS (
  SELECT DATE_TRUNC('day', o.order_purchase_timestamp) AS order_purchase_date,
         p.product_category_name,
         SUM(op.payment_value) AS category_revenue,
         false AS is_faulty
  FROM {{ ref('base_orders')}} o
  JOIN {{ ref('base_order_items')}} oi ON o.order_id = oi.order_id
  JOIN {{ ref('base_products')}} p ON oi.product_id = p.product_id
  JOIN {{ ref('base_order_payments')}}  op ON o.order_id = op.order_id
  GROUP BY 1, 2
), 

ranked_categories AS (
  SELECT order_purchase_date,
         product_category_name,
         category_revenue,
         ROW_NUMBER() OVER (PARTITION BY order_purchase_date) AS rank,
         false AS is_faulty
  FROM category_revenue
)
SELECT order_purchase_date,
       LISTAGG(product_category_name, ', ') WITHIN GROUP (ORDER BY rank) AS top_3_product_categories_by_revenue,
       is_faulty
FROM ranked_categories
WHERE rank <= 3
GROUP BY order_purchase_date, is_faulty