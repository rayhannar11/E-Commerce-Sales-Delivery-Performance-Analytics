-- Inventaris tabel dan jumlah baris dasar (jalankan setelah pemuatan).
SELECT 'customers' AS source_table, COUNT(*) AS rows FROM raw.olist_customers_dataset
UNION ALL SELECT 'orders', COUNT(*) FROM raw.olist_orders_dataset
UNION ALL SELECT 'items', COUNT(*) FROM raw.olist_order_items_dataset
UNION ALL SELECT 'payments', COUNT(*) FROM raw.olist_order_payments_dataset
UNION ALL SELECT 'reviews', COUNT(*) FROM raw.olist_order_reviews_dataset
UNION ALL SELECT 'products', COUNT(*) FROM raw.olist_products_dataset
UNION ALL SELECT 'sellers', COUNT(*) FROM raw.olist_sellers_dataset
UNION ALL SELECT 'geolocation', COUNT(*) FROM raw.olist_geolocation_dataset
UNION ALL SELECT 'category_translation', COUNT(*) FROM raw.product_category_name_translation;

SELECT MIN(order_purchase_timestamp) AS first_purchase,
       MAX(order_purchase_timestamp) AS last_purchase,
       COUNT(*) FILTER (WHERE order_status = 'delivered') AS delivered_orders,
       COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS missing_actual_delivery
FROM raw.olist_orders_dataset;
