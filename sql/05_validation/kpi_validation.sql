-- Pemeriksaan yang diharapkan: order_sales dan order_delivery masing-masing satu baris per order_id.
SELECT 'raw orders' AS check_name, COUNT(*)::bigint AS observed FROM raw.olist_orders_dataset
UNION ALL SELECT 'distinct raw order_id', COUNT(DISTINCT order_id) FROM raw.olist_orders_dataset
UNION ALL SELECT 'order_sales rows', COUNT(*) FROM analytics.order_sales
UNION ALL SELECT 'distinct order_sales order_id', COUNT(DISTINCT order_id) FROM analytics.order_sales
UNION ALL SELECT 'order_delivery rows', COUNT(*) FROM analytics.order_delivery
UNION ALL SELECT 'distinct order_delivery order_id', COUNT(DISTINCT order_id) FROM analytics.order_delivery;

-- Query pelanggaran tingkat rincian seharusnya tidak mengembalikan baris.
SELECT order_id, COUNT(*) AS rows_per_key FROM analytics.order_sales GROUP BY order_id HAVING COUNT(*) <> 1;
SELECT order_id, COUNT(*) AS rows_per_key FROM analytics.order_delivery GROUP BY order_id HAVING COUNT(*) <> 1;

-- Rekonsiliasi harga item dan model seharusnya nol pada populasi pesanan terkirim yang sama.
WITH raw_total AS (
  SELECT SUM(i.price) AS value FROM raw.olist_order_items_dataset i
  JOIN raw.olist_orders_dataset o USING (order_id) WHERE o.order_status = 'delivered'
), model_total AS (
  SELECT SUM(product_sales) AS value FROM analytics.order_sales WHERE order_status = 'delivered'
)
SELECT raw_total.value AS source_item_sales, model_total.value AS modeled_sales,
       raw_total.value - model_total.value AS difference
FROM raw_total CROSS JOIN model_total;

-- Pemeriksaan cakupan data dan hubungan satu-ke-banyak.
SELECT
  (SELECT COUNT(*) FROM analytics.order_sales WHERE customer_unique_id IS NULL) AS missing_customer_matches,
  (SELECT COUNT(*) FROM analytics.order_sales WHERE payment_total IS NULL) AS orders_without_payment_rows,
  (SELECT COUNT(*) FROM analytics.order_delivery WHERE avg_review_score IS NULL) AS orders_without_valid_review;
SELECT COUNT(*) AS orders_with_multiple_review_rows
FROM analytics.order_reviews WHERE review_rows > 1;
