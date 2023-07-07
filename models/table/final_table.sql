SELECT
  t.order_purchase_date,
  t.orders_count,
  c.customers_making_orders_count,
  r.revenue_usd,
  a.average_revenue_per_order_usd,
  b.top_3_product_categories_by_revenue,
  p.top_3_product_categories_revenue_percentage,
  b.is_faulty AS top_3_product_categories_is_faulty
FROM {{ ref('total_orders') }} t
JOIN {{ ref('total_customers') }} c USING (order_purchase_date)
JOIN {{ ref('total_revenue') }} r USING (order_purchase_date)
JOIN {{ ref('average_revenue_per_order') }} a USING (order_purchase_date)
JOIN {{ ref('top_3_product_categories_by_revenue') }} b USING (order_purchase_date)
JOIN {{ ref('top_3_product_categories_revenue_percentage') }} p USING (order_purchase_date);
