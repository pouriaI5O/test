-- model: total_orders
WITH total_orders AS (
  -- Calculate the total number of orders at the order purchase date grain
  SELECT DATE_TRUNC('day', order_purchase_date) AS order_purchase_date, -- Truncate the timestamp to the date
         COUNT(DISTINCT order_id) AS orders_count, -- Count the distinct order IDs
         false AS is_faulty -- Placeholder column for identifying faulty data
  FROM olist_orders
  GROUP BY 1
)
SELECT *
FROM total_orders;

-- model: total_customers_making_orders
WITH total_customers_making_orders AS (
  -- Calculate the total number of unique customers who made orders at the order purchase date grain
  SELECT DATE_TRUNC('day', order_purchase_date) AS order_purchase_date, -- Truncate the timestamp to the date
         COUNT(DISTINCT customer_id) AS customers_making_orders_count, -- Count the distinct customer IDs
         false AS is_faulty -- Placeholder column for identifying faulty data
  FROM olist_orders
  GROUP BY 1
)
SELECT *
FROM total_customers_making_orders;

-- model: total_revenue
WITH total_revenue AS (
  -- Calculate the total revenue generated at the order purchase date grain
  SELECT DATE_TRUNC('day', order_purchase_date) AS order_purchase_date, -- Truncate the timestamp to the date
         SUM(payment_value) AS revenue_usd, -- Sum the payment values
         false AS is_faulty -- Placeholder column for identifying faulty data
  FROM olist_order_payments
  GROUP BY 1
)
SELECT *
FROM total_revenue;

-- model: average_revenue_per_order
WITH average_revenue_per_order AS (
  -- Calculate the average revenue per order at the order purchase date grain
  SELECT DATE_TRUNC('day', order_purchase_date) AS order_purchase_date, -- Truncate the timestamp to the date
         SUM(payment_value) / COUNT(DISTINCT order_id) AS average_revenue_per_order_usd, -- Calculate the average revenue per order
         false AS is_faulty -- Placeholder column for identifying faulty data
  FROM olist_order_payments
  GROUP BY 1
)
SELECT *
FROM average_revenue_per_order;

-- model: top_3_product_categories_by_revenue
WITH category_revenue AS (
  -- Calculate the revenue for each product category at the order purchase date grain
  SELECT DATE_TRUNC('day', o.order_purchase_date) AS order_purchase_date, -- Truncate the timestamp to the date
         p.product_category_name,
         SUM(op.payment_value) AS category_revenue, -- Calculate the revenue for each category
         false AS is_faulty -- Placeholder column for identifying faulty data
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
         ROW_NUMBER() OVER (PARTITION BY order_purchase_date ORDER BY category_revenue DESC) AS rank -- Assign a rank based on revenue
  FROM category_revenue
)
SELECT order_purchase_date,
       STRING_AGG(product_category_name, ', ' ORDER BY rank) AS top_3_product_categories_by_revenue, -- Combine the top 3 categories into a comma-separated list
       false AS is_faulty -- Placeholder column for identifying faulty data
FROM ranked_categories
WHERE rank <= 3
GROUP BY 1;

-- model: top_3_product_categories_revenue_percentage
WITH daily_revenue AS (
  -- Calculate the daily revenue at the order purchase date grain
  SELECT DATE_TRUNC('day', op.order_purchase_date) AS order_purchase_date, -- Truncate the timestamp to the date
         SUM(op.payment_value) AS daily_revenue, -- Calculate the daily revenue
         false AS is_faulty -- Placeholder column for identifying faulty data
  FROM olist_order_payments op
  GROUP BY 1
),
top_categories_revenue AS (
  -- Calculate the revenue for the top 3 product categories and their percentage contribution for each order purchase date
  SELECT t.order_purchase_date,
         t.top_3_product_categories_by_revenue,
         SUM(c.category_revenue) AS top_3_revenue, -- Calculate the total revenue for the top 3 categories
         false AS is_faulty -- Placeholder column for identifying faulty data
  FROM top_3_product_categories_by_revenue t
  JOIN category_revenue c ON t.order_purchase_date = c.order_purchase_date
                          AND c.product_category_name IN (SELECT UNNEST(SPLIT_PART(t.top_3_product_categories_by_revenue, ', ')))
  GROUP BY 1, 2
)
SELECT t.order_purchase_date,
       STRING_AGG(FORMAT('%0.2f', c.category_revenue * 100 / t.top_3_revenue), ', ' ORDER BY c.product_category_name) AS top_3_product_categories_revenue_percentage, -- Combine the percentage values into a comma-separated list
       false AS is_faulty -- Placeholder column for identifying faulty data
FROM top_categories_revenue t
JOIN category_revenue c ON t.order_purchase_date = c.order_purchase_date
                        AND c.product_category_name IN (SELECT UNNEST(SPLIT_PART(t.top_3_product_categories_by_revenue, ', ')))
GROUP BY 1;
