-- DA-01/02: populasi pesanan dan cakupan tanggal ditampilkan dengan jelas.
SELECT COUNT(*) FILTER (WHERE order_status = 'delivered' AND delivery_days IS NOT NULL) AS delivery_time_orders,
       AVG(delivery_days) FILTER (WHERE order_status = 'delivered' AND delivery_days >= 0) AS avg_delivery_days,
       COUNT(*) FILTER (WHERE order_status = 'delivered' AND is_late IS NOT NULL) AS late_eligible_orders,
       AVG(is_late::int) FILTER (WHERE order_status = 'delivered' AND is_late IS NOT NULL) AS late_delivery_rate
FROM analytics.order_delivery;

-- DA-03: peringkat negara bagian hanya mencakup minimal 100 pesanan dengan kedua tanggal valid.
SELECT customer_state, COUNT(*) AS eligible_orders,
       AVG(is_late::int) AS late_delivery_rate, SUM(is_late::int) AS late_orders
FROM analytics.order_delivery
WHERE order_status = 'delivered' AND is_late IS NOT NULL
GROUP BY customer_state HAVING COUNT(*) >= 100
ORDER BY late_delivery_rate DESC;

-- DA-04: item mengikuti status pesanan; hitung pesanan unik di setiap kategori.
WITH item_category AS (
  SELECT DISTINCT i.order_id, COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
         d.is_late
  FROM raw.olist_order_items_dataset i
  JOIN analytics.order_delivery d ON d.order_id = i.order_id
  LEFT JOIN raw.olist_products_dataset p ON p.product_id = i.product_id
  LEFT JOIN raw.product_category_name_translation t ON t.product_category_name = p.product_category_name
  WHERE d.order_status = 'delivered' AND d.is_late IS NOT NULL
)
SELECT category, COUNT(DISTINCT order_id) AS eligible_orders,
       COUNT(DISTINCT order_id) FILTER (WHERE is_late) AS late_orders,
       AVG(is_late::int) AS late_delivery_rate
FROM item_category GROUP BY category HAVING COUNT(DISTINCT order_id) >= 100
ORDER BY late_delivery_rate DESC;

-- DA-05/06: skor adalah rata-rata ulasan valid per pesanan; ulasan tidak digabung hingga menggandakan baris.
SELECT CASE WHEN is_late THEN 'Late' ELSE 'On time' END AS delivery_status,
       COUNT(*) AS reviewed_orders, AVG(avg_review_score) AS avg_review_score,
       AVG((avg_review_score <= 2)::int) AS low_rating_rate
FROM analytics.order_delivery
WHERE order_status = 'delivered' AND is_late IS NOT NULL AND avg_review_score IS NOT NULL
GROUP BY 1 ORDER BY 1;
