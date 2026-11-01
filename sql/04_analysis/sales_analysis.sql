-- SA-01/02: pesanan terkirim dengan total item yang tersedia.
SELECT COUNT(*) FILTER (WHERE order_status = 'delivered') AS delivered_orders,
       COUNT(*) FILTER (WHERE order_status = 'delivered' AND product_sales IS NOT NULL) AS sales_valid_orders,
       SUM(product_sales) FILTER (WHERE order_status = 'delivered') AS product_sales,
       SUM(freight_charges) FILTER (WHERE order_status = 'delivered') AS freight_charges,
       SUM(product_sales) FILTER (WHERE order_status = 'delivered') /
         NULLIF(COUNT(*) FILTER (WHERE order_status = 'delivered' AND product_sales IS NOT NULL), 0) AS aov_product_sales
FROM analytics.order_sales;

-- SA-03: tren berdasarkan bulan pembelian; MoM NULL jika data bulan sebelumnya tidak ada atau nol.
WITH monthly AS (
  SELECT DATE_TRUNC('month', order_purchase_timestamp)::date AS purchase_month,
         SUM(product_sales) AS product_sales, COUNT(*) AS delivered_orders
  FROM analytics.order_sales
  WHERE order_status = 'delivered' AND product_sales IS NOT NULL
  GROUP BY 1
), lagged AS (
  SELECT *,
         LAG(purchase_month) OVER (ORDER BY purchase_month) AS prior_purchase_month,
         LAG(product_sales) OVER (ORDER BY purchase_month) AS prior_month_sales
  FROM monthly
)
SELECT *,
       CASE WHEN purchase_month = (prior_purchase_month + INTERVAL '1 month')::date
                  AND prior_month_sales <> 0
            THEN product_sales / prior_month_sales - 1 END AS mom_growth
FROM lagged ORDER BY purchase_month;

-- SA-04: sepuluh kategori teratas berdasarkan penjualan produk pada pesanan terkirim.
SELECT category, delivered_orders, order_items, product_sales
FROM analytics.product_category_sales ORDER BY product_sales DESC LIMIT 10;

-- SA-05: gunakan negara bagian pelanggan, bukan penjual; sertakan jumlah pesanan.
SELECT customer_state, COUNT(*) AS delivered_orders, SUM(product_sales) AS product_sales
FROM analytics.order_sales
WHERE order_status = 'delivered' AND product_sales IS NOT NULL
GROUP BY customer_state ORDER BY product_sales DESC;
