-- model: total_orders
WITH total_orders AS (
  -- Calculate the total number of orders at the order purchase date grain
  SELECT DATE_TRUNC('day', order_purchase_date) AS order_purchase_date,
         COUNT(DISTINCT order_id) AS orders_count,
         false AS is_faulty
  FROM olist_orders
  GROUP BY 1
)
SELECT *
FROM total_orders;

-- model: total_customers_making_orders
WITH total_customers_making_orders AS (
  -- Calculate the total number of unique customers who made orders at the order purchase date grain
  SELECT DATE_TRUNC('day', order_purchase_date) AS order_purchase_date,
         COUNT(DISTINCT customer_id) AS customers_making_orders_count,
         false AS is_faulty
  FROM olist_orders
  GROUP BY 1
)
SELECT *
FROM total_customers_making_orders;

-- model: total_revenue
WITH total_revenue AS (
  -- Calculate the total revenue generated at the order purchase date grain
  SELECT DATE_TRUNC('day', order_purchase_date) AS order_purchase_date,
         SUM(payment_value) AS revenue_usd,
         false AS is_faulty
  FROM olist_order_payments
  GROUP BY 1
)
SELECT *
FROM total_revenue;

-- model: average_revenue_per_order
WITH average_revenue_per_order AS (
  -- Calculate the average revenue per order at the order purchase date grain
  SELECT DATE_TRUNC('day', order_purchase_date) AS order_purchase_date,
         SUM(payment_value) / COUNT(DISTINCT order_id) AS average_revenue_per_order_usd,
         false AS is_faulty
  FROM olist_order_payments
  GROUP BY 1
)
SELECT *
FROM average_revenue_per_order;

-- model: top_3_product_categories_by_revenue
WITH category_revenue AS (
  -- Calculate the revenue for each product category at the order purchase date grain
  SELECT DATE_TRUNC('day', o.order_purchase_date) AS order_purchase_date,
         p.product_category_name,
         SUM(op.payment_value) AS category_revenue,
         false AS is_faulty
  FROM olist_orders o
  JOIN olist_order_items oi ON o.order_id = oi.order_id
  JOIN olist_products p ON oi.product_id = p.product_id
  JOIN olist_order_payments op ON o.order_id = op.order_id
  GROUP BY 1, 2
),
ranked_categories AS (
  -- Rank the product categories by revenue for each order purchase date
  SELECT order_purchase_date,
         product_category_name,
         category_revenue,
         ROW_NUMBER() OVER (PARTITION BY order_purchase_date ORDER BY category_revenue DESC) AS rank
  FROM category_revenue
)
SELECT order_purchase_date,
       STRING_AGG(product_category_name, ', ' ORDER BY rank) AS top_3_product_categories_by_revenue,
       false AS is_faulty
FROM ranked_categories
WHERE rank <= 3
GROUP BY 1;

-- model: top_3_product_categories_revenue_percentage
WITH daily_revenue AS (
  -- Calculate the daily revenue at the order purchase date grain
  SELECT DATE_TRUNC('day', op.order_purchase_date) AS order_purchase_date,
         SUM(op.payment_value) AS daily_revenue,
         false AS is_faulty
  FROM olist_order_payments op
  GROUP BY 1
),
top_categories_revenue AS (
  -- Calculate the revenue for the top 3 product categories and their percentage contribution for each order purchase date
  SELECT t.order_purchase_date,
         t.top_3_product_categories_by_revenue,
         SUM(c.category_revenue) AS top_3_revenue,
         false AS is_faulty
  FROM top_3_product_categories_by_revenue t
  JOIN category_revenue c ON t.order_purchase_date = c.order_purchase_date
                          AND c.product_category_name IN (SELECT UNNEST(SPLIT_PART(t.top_3_product_categories_by_revenue, ', ')))
  GROUP BY 1, 2
)
SELECT t.order_purchase_date,
       STRING_AGG(FORMAT('%0.2f', c.category_revenue * 100 / t.top_3_revenue), ', ' ORDER BY c.product_category_name) AS top_3_product_categories_revenue_percentage,
       false AS is_faulty
FROM top_categories_revenue t
JOIN category_revenue c ON t.order_purchase_date = c.order_purchase_date
                        AND c.product_category_name IN (SELECT UNNEST(SPLIT_PART(t.top_3_product_categories_by_revenue, ', ')))
GROUP BY 1;
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
