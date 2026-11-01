# Kamus data

## Cakupan

Sembilan CSV Olist periode 2016–2018 dimuat ke skema `raw`. Jumlah baris hasil muat tercatat di [manifest data](../data/dataset_manifest.csv) dan [laporan kualitas](data_quality_report.md). Definisi di bawah mengikuti kolom sumber; baris raw tidak dihapus atau diubah.

## Tabel pelanggan — `olist_customers_dataset`

**Grain:** satu rekaman per `customer_id` (99.441 baris). `customer_unique_id` adalah identitas lintas rekaman yang dipakai untuk KPI pelanggan setelah dikaitkan ke order.

| Kolom | Arti | Catatan |
|---|---|---|
| `customer_id` | ID rekaman pelanggan | Unik pada file ini; dipakai order sebagai FK |
| `customer_unique_id` | Identitas pelanggan lintas order | 96.096 identitas; bukan order ID |
| `customer_zip_code_prefix` | Prefix kode pos | Simpan sebagai teks; dapat berasosiasi dengan beberapa kota |
| `customer_city` | Label kota | Teks sumber, lowercase/tanpa aksen |
| `customer_state` | Kode negara bagian Brasil | 27 kode UF |

## Tabel pesanan — `olist_orders_dataset`

**Grain:** satu baris per `order_id` (99.441 baris).

| Kolom | Arti |
|---|---|
| `order_id` | ID pesanan |
| `customer_id` | Rekaman pelanggan yang membuat pesanan |
| `order_status` | Status pesanan; populasi KPI penjualan utama adalah `delivered` |
| `order_purchase_timestamp` | Waktu checkout/pembelian |
| `order_approved_at` | Waktu pembayaran disetujui |
| `order_delivered_carrier_date` | Waktu diserahkan ke kurir |
| `order_delivered_customer_date` | Waktu diterima pelanggan |
| `order_estimated_delivery_date` | Tanggal estimasi tiba |

## Tabel item pesanan — `olist_order_items_dataset`

**Grain:** satu baris per `(order_id, order_item_id)` (112.650 baris). Harga item diagregasi sebelum join ke order.

| Kolom | Arti |
|---|---|
| `order_id`, `order_item_id` | Pesanan dan nomor item di dalamnya |
| `product_id`, `seller_id` | Produk dan penjual |
| `shipping_limit_date` | Batas waktu penyerahan ke kurir |
| `price` | Harga item; dipakai sebagai penjualan produk |
| `freight_value` | Ongkos kirim item; tidak digabung ke penjualan produk |

## Tabel pembayaran — `olist_order_payments_dataset`

**Grain:** satu baris per urutan pembayaran dalam pesanan (103.886 baris).

| Kolom | Arti |
|---|---|
| `order_id`, `payment_sequential` | Pesanan dan urutan pembayaran |
| `payment_type` | Jenis/metode pembayaran |
| `payment_installments` | Jumlah cicilan |
| `payment_value` | Nilai pembayaran |

Satu order tidak memiliki baris pembayaran. Pembayaran diagregasi terpisah agar join tidak menggandakan harga item.

## Tabel ulasan — `olist_order_reviews_dataset`

**Grain:** satu baris ulasan untuk suatu order; satu order dapat memiliki beberapa baris (99.224 baris).

| Kolom | Arti |
|---|---|
| `review_id`, `order_id` | Identitas ulasan sumber dan pesanan |
| `review_score` | Skor 1–5 |
| `review_comment_title`, `review_comment_message` | Judul dan teks ulasan; banyak nilai kosong |
| `review_creation_date`, `review_answer_timestamp` | Tanggal ulasan dibuat dan dijawab |

`review_id` dipakai ulang pada beberapa order sehingga bukan key tunggal. Kunci komposit `(order_id, review_id)` unik pada file ini. Skor valid dirata-ratakan di tingkat order sebelum dibandingkan dengan status pengiriman.

## Tabel produk — `olist_products_dataset`

**Grain:** satu baris per `product_id` (32.951 baris).

| Kolom | Arti |
|---|---|
| `product_id` | ID produk |
| `product_category_name` | Kategori sumber dalam bahasa Portugis |
| `product_name_lenght`, `product_description_lenght` | Panjang nama dan deskripsi, sesuai ejaan kolom sumber |
| `product_photos_qty` | Jumlah foto |
| `product_weight_g` | Berat dalam gram |
| `product_length_cm`, `product_height_cm`, `product_width_cm` | Dimensi dalam sentimeter |

Sebagian atribut produk kosong; hal ini tidak mengubah penjumlahan harga item.

## Tabel penjual — `olist_sellers_dataset`

**Grain:** satu baris per `seller_id` (3.095 baris).

| Kolom | Arti |
|---|---|
| `seller_id` | ID penjual |
| `seller_zip_code_prefix` | Prefix kode pos penjual |
| `seller_city`, `seller_state` | Label kota dan negara bagian |

## Tabel geolokasi — `olist_geolocation_dataset`

**Grain:** beberapa titik dapat berasosiasi dengan prefix kode pos (1.000.163 baris).

| Kolom | Arti |
|---|---|
| `geolocation_zip_code_prefix` | Prefix kode pos |
| `geolocation_lat`, `geolocation_lng` | Koordinat lintang dan bujur |
| `geolocation_city`, `geolocation_state` | Label kota dan negara bagian |

Tabel memiliki baris identik dan hubungan prefix-ke-kota tidak selalu satu-ke-satu. Tabel ini tidak digabungkan ke fact penjualan/pengiriman.

## Terjemahan kategori — `product_category_name_translation`

**Grain:** satu baris per nama kategori (71 baris).

| Kolom | Arti |
|---|---|
| `product_category_name` | Nama kategori sumber |
| `product_category_name_english` | Label kategori bahasa Inggris |

Relasi dan grain tabel ditunjukkan pada [ERD](../images/erd.png); definisi KPI serta populasi analisis ada di [metodologi](methodology.md).
