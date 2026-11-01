-- Pemeriksaan profil PostgreSQL untuk tabel pelanggan.
-- Muat nilai sumber tanpa mengubah CSV; simpan prefix kode pos sebagai TEXT.
-- Tabel yang diperiksa: raw.olist_customers_dataset

-- 1. Jumlah baris
SELECT COUNT(*) AS row_count
FROM raw.olist_customers_dataset;

-- 2. Nilai kosong per kolom
SELECT
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer_id,
    COUNT(*) FILTER (WHERE customer_unique_id IS NULL) AS missing_customer_unique_id,
    COUNT(*) FILTER (WHERE customer_zip_code_prefix IS NULL) AS missing_zip_prefix,
    COUNT(*) FILTER (WHERE customer_city IS NULL OR BTRIM(customer_city) = '') AS missing_or_blank_city,
    COUNT(*) FILTER (WHERE customer_state IS NULL OR BTRIM(customer_state) = '') AS missing_or_blank_state
FROM raw.olist_customers_dataset;

-- 3. Keunikan key
SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT customer_id) AS distinct_customer_id,
    COUNT(DISTINCT customer_unique_id) AS distinct_customer_unique_id
FROM raw.olist_customers_dataset;

-- 4. Duplikat seluruh baris (hasil yang diharapkan: tidak ada baris)
SELECT customer_id, customer_unique_id, customer_zip_code_prefix,
       customer_city, customer_state, COUNT(*) AS copies
FROM raw.olist_customers_dataset
GROUP BY customer_id, customer_unique_id, customer_zip_code_prefix,
         customer_city, customer_state
HAVING COUNT(*) > 1
ORDER BY copies DESC;

-- 5. Jumlah rekaman per identitas pelanggan lintas pesanan
SELECT record_count, COUNT(*) AS identity_count
FROM (
    SELECT customer_unique_id, COUNT(*) AS record_count
    FROM raw.olist_customers_dataset
    GROUP BY customer_unique_id
) AS identity_frequency
GROUP BY record_count
ORDER BY record_count;

-- 6. Prefix kode pos yang memiliki lebih dari satu label kota
SELECT customer_zip_code_prefix,
       COUNT(DISTINCT customer_city) AS city_count,
       ARRAY_AGG(DISTINCT customer_city ORDER BY customer_city) AS city_labels
FROM raw.olist_customers_dataset
GROUP BY customer_zip_code_prefix
HAVING COUNT(DISTINCT customer_city) > 1
ORDER BY city_count DESC, customer_zip_code_prefix;

-- 7. Sebaran rekaman menurut negara bagian
SELECT customer_state, COUNT(*) AS customer_records,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS record_share_pct
FROM raw.olist_customers_dataset
GROUP BY customer_state
ORDER BY customer_records DESC;
