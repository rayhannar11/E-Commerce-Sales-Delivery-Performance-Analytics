-- CA-01/02: populasi yang dihitung adalah pelanggan dengan setidaknya satu pesanan terkirim.
WITH customer_orders AS (
  SELECT customer_unique_id, COUNT(DISTINCT order_id) AS delivered_orders,
         SUM(product_sales) AS product_spend
  FROM analytics.order_sales
  WHERE order_status = 'delivered' AND customer_unique_id IS NOT NULL
  GROUP BY customer_unique_id
)
SELECT COUNT(*) AS unique_customers,
       COUNT(*) FILTER (WHERE delivered_orders >= 2) AS repeat_customers,
       COUNT(*) FILTER (WHERE delivered_orders >= 2)::numeric / NULLIF(COUNT(*), 0) AS repeat_purchase_rate,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY product_spend) AS median_spend
FROM customer_orders;

-- CA-03: sebaran belanja per pelanggan.
SELECT CASE WHEN product_spend <= 100 THEN '≤ R$100'
            WHEN product_spend <= 500 THEN 'R$100–500'
            WHEN product_spend <= 1500 THEN 'R$500–1.500'
            ELSE '> R$1.500' END AS spend_band,
       COUNT(*) AS customers, SUM(product_spend) AS product_spend
FROM analytics.customer_summary GROUP BY 1 ORDER BY MIN(product_spend);

-- CA-04: lihat analytics.customer_rfm untuk snapshot yang terdokumentasi dan satu baris per identitas.
SELECT rfm_segment, COUNT(*) AS customers,
       AVG(product_spend) AS avg_product_spend,
       MIN(last_purchase_timestamp) AS earliest_last_purchase,
       MAX(last_purchase_timestamp) AS latest_last_purchase
FROM analytics.customer_rfm GROUP BY rfm_segment ORDER BY customers DESC;
