CREATE OR REPLACE VIEW analytics.order_item_totals AS
SELECT order_id, COUNT(*) AS item_count, SUM(price) AS product_sales,
       SUM(freight_value) AS freight_charges
FROM raw.olist_order_items_dataset
GROUP BY order_id;

CREATE OR REPLACE VIEW analytics.order_payment_totals AS
SELECT order_id, COUNT(*) AS payment_rows, SUM(payment_value) AS payment_total
FROM raw.olist_order_payments_dataset
GROUP BY order_id;

-- Satu baris per pesanan; setiap tabel satu-ke-banyak diringkas sebelum digabung.
CREATE OR REPLACE VIEW analytics.order_sales AS
SELECT o.order_id, o.customer_id, c.customer_unique_id, c.customer_state,
       o.order_status, o.order_purchase_timestamp, o.order_purchase_timestamp::date AS purchase_date,
       i.item_count, i.product_sales, i.freight_charges,
       p.payment_rows, p.payment_total
FROM raw.olist_orders_dataset o
LEFT JOIN raw.olist_customers_dataset c ON c.customer_id = o.customer_id
LEFT JOIN analytics.order_item_totals i ON i.order_id = o.order_id
LEFT JOIN analytics.order_payment_totals p ON p.order_id = o.order_id;

CREATE OR REPLACE VIEW analytics.order_reviews AS
SELECT order_id, COUNT(*) AS review_rows, AVG(review_score)::numeric(8,4) AS avg_review_score,
       BOOL_OR(review_score <= 2) AS has_low_review
FROM raw.olist_order_reviews_dataset
WHERE review_score BETWEEN 1 AND 5
GROUP BY order_id;

CREATE OR REPLACE VIEW analytics.order_delivery AS
SELECT o.order_id, o.customer_id, c.customer_unique_id, c.customer_state,
       o.order_status, o.order_purchase_timestamp,
       o.order_delivered_customer_date, o.order_estimated_delivery_date,
       EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) / 86400.0 AS delivery_days,
       CASE WHEN o.order_status = 'delivered'
                  AND o.order_delivered_customer_date IS NOT NULL
                  AND o.order_estimated_delivery_date IS NOT NULL
                  AND o.order_delivered_customer_date >= o.order_purchase_timestamp
            THEN o.order_delivered_customer_date > o.order_estimated_delivery_date END AS is_late,
       r.review_rows, r.avg_review_score,
       CASE WHEN r.avg_review_score <= 2 THEN TRUE
            WHEN r.avg_review_score > 2 THEN FALSE END AS low_rating
FROM raw.olist_orders_dataset o
LEFT JOIN raw.olist_customers_dataset c ON c.customer_id = o.customer_id
LEFT JOIN analytics.order_reviews r ON r.order_id = o.order_id;

CREATE OR REPLACE VIEW analytics.customer_summary AS
SELECT customer_unique_id, COUNT(DISTINCT order_id) AS delivered_orders,
       SUM(product_sales) AS product_spend,
       MAX(order_purchase_timestamp) AS last_purchase_timestamp
FROM analytics.order_sales
WHERE order_status = 'delivered' AND customer_unique_id IS NOT NULL
GROUP BY customer_unique_id;

-- Snapshot RFM yang dapat diulang: satu hari setelah pembelian terkirim terakhir yang tercatat.
CREATE OR REPLACE VIEW analytics.customer_rfm AS
WITH snapshot AS (
  SELECT MAX(last_purchase_timestamp) + INTERVAL '1 day' AS snapshot_timestamp
  FROM analytics.customer_summary
), scored AS (
  SELECT c.customer_unique_id, c.delivered_orders, c.product_spend,
         c.last_purchase_timestamp,
         (s.snapshot_timestamp::date - c.last_purchase_timestamp::date) AS recency_days,
         6 - NTILE(5) OVER (ORDER BY c.last_purchase_timestamp DESC, c.customer_unique_id) AS r_score,
         NTILE(5) OVER (ORDER BY c.delivered_orders, c.customer_unique_id) AS f_score,
         NTILE(5) OVER (ORDER BY c.product_spend, c.customer_unique_id) AS m_score
  FROM analytics.customer_summary c CROSS JOIN snapshot s
), segmented AS (
  SELECT *, CASE WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
                 WHEN r_score <= 2 AND f_score >= 3 THEN 'At risk'
                 WHEN r_score >= 4 AND f_score = 1 THEN 'New customers'
                 ELSE 'Potential loyalists' END AS rfm_segment
  FROM scored
)
SELECT *, r_score::text || f_score::text || m_score::text AS rfm_code
FROM segmented;

CREATE OR REPLACE VIEW analytics.product_category_sales AS
SELECT COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
       COUNT(*) AS order_items, COUNT(DISTINCT i.order_id) AS delivered_orders,
       SUM(i.price) AS product_sales, SUM(i.freight_value) AS freight_charges
FROM raw.olist_order_items_dataset i
JOIN raw.olist_orders_dataset o ON o.order_id = i.order_id AND o.order_status = 'delivered'
LEFT JOIN raw.olist_products_dataset p ON p.product_id = i.product_id
LEFT JOIN raw.product_category_name_translation t ON t.product_category_name = p.product_category_name
GROUP BY 1;

-- Ringkasan untuk dashboard; setiap view sudah sesuai tingkat rincian visualnya.
CREATE OR REPLACE VIEW analytics.monthly_sales AS
SELECT DATE_TRUNC('month', order_purchase_timestamp)::date AS purchase_month,
       COUNT(*) AS delivered_orders, SUM(product_sales) AS product_sales,
       SUM(freight_charges) AS freight_charges
FROM analytics.order_sales
WHERE order_status = 'delivered'
GROUP BY 1;

CREATE OR REPLACE VIEW analytics.sales_by_state AS
SELECT customer_state, COUNT(*) AS delivered_orders,
       SUM(product_sales) AS product_sales, SUM(freight_charges) AS freight_charges
FROM analytics.order_sales
WHERE order_status = 'delivered'
GROUP BY customer_state;

CREATE OR REPLACE VIEW analytics.delivery_by_state AS
SELECT customer_state, COUNT(*) AS eligible_orders,
       COUNT(*) FILTER (WHERE is_late) AS late_orders,
       AVG(is_late::int)::numeric(8,5) AS late_rate
FROM analytics.order_delivery
WHERE order_status = 'delivered' AND is_late IS NOT NULL
GROUP BY customer_state
HAVING COUNT(*) >= 100;

CREATE OR REPLACE VIEW analytics.delivery_by_category AS
WITH category_order AS (
  SELECT DISTINCT i.order_id,
         COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
         d.is_late
  FROM raw.olist_order_items_dataset i
  JOIN analytics.order_delivery d ON d.order_id = i.order_id
  LEFT JOIN raw.olist_products_dataset p ON p.product_id = i.product_id
  LEFT JOIN raw.product_category_name_translation t ON t.product_category_name = p.product_category_name
  WHERE d.order_status = 'delivered' AND d.is_late IS NOT NULL
)
SELECT category, COUNT(*) AS eligible_orders,
       COUNT(*) FILTER (WHERE is_late) AS late_orders,
       AVG(is_late::int)::numeric(8,5) AS late_rate
FROM category_order
GROUP BY category
HAVING COUNT(*) >= 100;

CREATE OR REPLACE VIEW analytics.review_by_delivery_status AS
SELECT CASE WHEN is_late THEN 'Late' ELSE 'On time' END AS delivery_status,
       COUNT(*) AS reviewed_orders, AVG(avg_review_score)::numeric(8,4) AS avg_review_score,
       AVG((avg_review_score <= 2)::int)::numeric(8,5) AS low_rating_rate
FROM analytics.order_delivery
WHERE order_status = 'delivered' AND is_late IS NOT NULL AND avg_review_score IS NOT NULL
GROUP BY 1;
