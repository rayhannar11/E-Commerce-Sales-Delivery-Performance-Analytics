-- Pemeriksaan key ganda; data raw tetap dipertahankan meskipun ditemukan masalah.
SELECT 'customer_id duplicate rows' AS check_name, COALESCE(SUM(n - 1), 0) AS excess_rows
FROM (SELECT customer_id, COUNT(*) AS n FROM raw.olist_customers_dataset GROUP BY customer_id HAVING COUNT(*) > 1) x
UNION ALL SELECT 'order_id duplicate rows', COALESCE(SUM(n - 1), 0)
FROM (SELECT order_id, COUNT(*) AS n FROM raw.olist_orders_dataset GROUP BY order_id HAVING COUNT(*) > 1) x
UNION ALL SELECT 'order item key duplicate rows', COALESCE(SUM(n - 1), 0)
FROM (SELECT order_id, order_item_id, COUNT(*) AS n FROM raw.olist_order_items_dataset GROUP BY 1,2 HAVING COUNT(*) > 1) x
UNION ALL SELECT 'payment sequence duplicate rows', COALESCE(SUM(n - 1), 0)
FROM (SELECT order_id, payment_sequential, COUNT(*) AS n FROM raw.olist_order_payments_dataset GROUP BY 1,2 HAVING COUNT(*) > 1) x
UNION ALL SELECT 'order_id + review_id duplicate rows', COALESCE(SUM(n - 1), 0)
FROM (SELECT order_id, review_id, COUNT(*) AS n FROM raw.olist_order_reviews_dataset GROUP BY 1,2 HAVING COUNT(*) > 1) x;

-- review_id dapat digunakan ulang di pesanan berbeda, jadi bukan key unik untuk seluruh dataset.
SELECT COUNT(*) AS review_ids_reused_across_orders
FROM (SELECT review_id FROM raw.olist_order_reviews_dataset GROUP BY review_id HAVING COUNT(DISTINCT order_id) > 1) x;

-- Kecocokan relasi antartabel. Geolokasi tidak disertakan karena prefix kode pos tidak unik.
SELECT 'orders without customer record' AS check_name, COUNT(*) AS affected_rows
FROM raw.olist_orders_dataset o LEFT JOIN raw.olist_customers_dataset c USING (customer_id)
WHERE c.customer_id IS NULL
UNION ALL SELECT 'items without order', COUNT(*)
FROM raw.olist_order_items_dataset i LEFT JOIN raw.olist_orders_dataset o USING (order_id)
WHERE o.order_id IS NULL
UNION ALL SELECT 'items without product', COUNT(*)
FROM raw.olist_order_items_dataset i LEFT JOIN raw.olist_products_dataset p USING (product_id)
WHERE p.product_id IS NULL
UNION ALL SELECT 'items without seller', COUNT(*)
FROM raw.olist_order_items_dataset i LEFT JOIN raw.olist_sellers_dataset s USING (seller_id)
WHERE s.seller_id IS NULL;

-- Rentang nilai angka dan urutan tanggal.
SELECT 'negative item price' AS check_name, COUNT(*) AS affected_rows FROM raw.olist_order_items_dataset WHERE price < 0
UNION ALL SELECT 'negative freight', COUNT(*) FROM raw.olist_order_items_dataset WHERE freight_value < 0
UNION ALL SELECT 'review score outside 1-5', COUNT(*) FROM raw.olist_order_reviews_dataset WHERE review_score NOT BETWEEN 1 AND 5
UNION ALL SELECT 'delivery before purchase', COUNT(*) FROM raw.olist_orders_dataset
 WHERE order_delivered_customer_date < order_purchase_timestamp;

-- Cakupan KPI pengiriman dan pesanan dengan beberapa ulasan.
SELECT COUNT(*) FILTER (WHERE order_status = 'delivered') AS delivered_orders,
       COUNT(*) FILTER (WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL) AS missing_actual_date,
       COUNT(*) FILTER (WHERE order_status = 'delivered' AND order_estimated_delivery_date IS NULL) AS missing_estimate_date
FROM raw.olist_orders_dataset;
SELECT COUNT(*) AS orders_with_multiple_review_rows
FROM (SELECT order_id FROM raw.olist_order_reviews_dataset GROUP BY order_id HAVING COUNT(*) > 1) r;
SELECT COUNT(*) AS orders_without_valid_review_score
FROM raw.olist_orders_dataset o
LEFT JOIN (
  SELECT order_id, AVG(review_score) AS avg_review_score
  FROM raw.olist_order_reviews_dataset WHERE review_score BETWEEN 1 AND 5
  GROUP BY order_id
) r USING (order_id)
WHERE r.avg_review_score IS NULL;
