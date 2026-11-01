# PRD Dashboard Power BI — Olist Sales & Delivery

Dokumen ini menjadi spesifikasi dashboard sekaligus prompt siap salin untuk AI pembuat laporan Power BI. Gunakan bersama `powerbi_measures.dax`, `powerbi_theme.json`, dan view PostgreSQL pada skema `analytics`.

## 1. Tujuan

Buat laporan Power BI tiga halaman untuk menjawab pertanyaan utama:

> Bagaimana ketepatan pengiriman berkaitan dengan kepuasan pelanggan, dan segmen operasional mana yang perlu diperiksa lebih dahulu?

Analisis mencakup data historis Olist Brasil periode 2016–2018. Pengguna utama adalah manajer operasi, customer experience, sales, dan reviewer portofolio. Dashboard harus membantu pembaca memahami volume, tingkat keterlambatan, perbedaan rating, serta konteks penjualan dan pelanggan.

## 2. Sumber data

- Database PostgreSQL: `olist_ecommerce_analytics`
- Skema Power BI: `analytics`
- Koneksi lokal: `localhost:5432`, mode **Import**
- Kredensial dimasukkan langsung oleh pemilik di Power BI. Jangan menulis atau menyimpan password dalam file, prompt, DAX, atau screenshot.
- Untuk koneksi `localhost` pada komputer yang sama, ikuti pengaturan enkripsi di [panduan koneksi](../docs/postgresql_powerbi_guide.md). Jangan menonaktifkan enkripsi untuk server jaringan.

### View yang tersedia

| View | Grain | Kolom utama |
|---|---|---|
| `order_sales` | satu baris per `order_id` | `order_id`, `customer_unique_id`, `customer_state`, `order_status`, `purchase_date`, `product_sales`, `freight_charges`, `payment_total` |
| `order_delivery` | satu baris per `order_id` | `order_id`, `customer_state`, `order_status`, `delivery_days`, `is_late`, `avg_review_score`, `low_rating` |
| `customer_summary` | satu baris per `customer_unique_id` | `customer_unique_id`, `delivered_orders`, `product_spend`, `last_purchase_timestamp` |
| `customer_rfm` | satu baris per `customer_unique_id` | `customer_unique_id`, `delivered_orders`, `product_spend`, `recency_days`, `r_score`, `f_score`, `m_score`, `rfm_segment`, `rfm_code` |
| `monthly_sales` | satu baris per bulan | `purchase_month`, `delivered_orders`, `product_sales`, `freight_charges` |
| `product_category_sales` | satu baris per kategori | `category`, `order_items`, `delivered_orders`, `product_sales`, `freight_charges` |
| `sales_by_state` | satu baris per negara bagian pelanggan | `customer_state`, `delivered_orders`, `product_sales`, `freight_charges` |
| `delivery_by_state` | satu baris per negara bagian, minimal 100 order eligible | `customer_state`, `eligible_orders`, `late_orders`, `late_rate` |
| `delivery_by_category` | satu baris per kategori, minimal 100 order eligible | `category`, `eligible_orders`, `late_orders`, `late_rate` |
| `review_by_delivery_status` | satu baris per status pengiriman | `delivery_status`, `reviewed_orders`, `avg_review_score`, `low_rating_rate` |

Gunakan view `analytics`; jangan memakai tabel `raw` untuk membuat visual. Item, payment, dan review sudah diproses agar metrik order tidak terduplikasi. Jangan gabungkan view fakta atau ringkasan secara langsung hanya karena memiliki kolom bernama sama. Tiap view memiliki grain berbeda. Buat slicer lintas visual hanya jika relasi model benar-benar meneruskan filternya; jika perlu, minta view SQL tambahan dengan grain yang dinyatakan jelas.

## 3. Definisi KPI

- **Product Sales:** jumlah `price` item pada order berstatus delivered. Freight dilaporkan terpisah.
- **Delivered Orders:** jumlah order unik dengan status delivered.
- **AOV:** Product Sales dibagi jumlah order delivered dengan nilai penjualan item yang valid.
- **Delivery Days:** selisih tanggal pembelian dan tanggal pelanggan menerima pesanan; hanya tanggal valid dan durasi non-negatif.
- **Late Delivery Rate:** order delivered yang tanggal aktualnya melewati tanggal estimasi, dibagi order delivered dengan kedua tanggal valid.
- **Review Score:** rata-rata skor valid pada grain order. Untuk perbandingan on-time vs late, gunakan view `review_by_delivery_status`.
- **Low Rating:** skor rata-rata order ≤2; denominator hanya order dengan skor valid.
- **Repeat Purchase Rate:** identitas pelanggan (`customer_unique_id`) dengan minimal dua order delivered, dibagi identitas dengan minimal satu order delivered.
- **RFM:** gunakan segmen dan skor yang sudah tersedia pada `customer_rfm`; jangan menghitung ulang batas segmen dengan aturan berbeda.

Harga item bukan profit atau pendapatan bersih. Hubungan keterlambatan dan rating bersifat observasional dan tidak membuktikan sebab-akibat.

## 4. Halaman dashboard

### Halaman 1 — Sales Overview

**Tujuan:** menunjukkan skala penjualan dan perubahannya selama periode data.

- Kartu: Product Sales, Delivered Orders, Average Order Value, Freight Charges.
- Grafik garis: `monthly_sales.purchase_month` terhadap `monthly_sales.product_sales`.
- Bar horizontal: 10 kategori teratas dari `product_category_sales.category` dan `product_sales`.
- Bar horizontal: penjualan menurut `sales_by_state.customer_state`; sertakan jumlah order pada tooltip.
- Filter tanggal hanya ditampilkan jika filter benar-benar berlaku pada visual terkait.
- Tampilkan rentang tanggal analisis dan tandai bulan terakhir sebagai parsial bila cakupan sumber belum satu bulan penuh. Jangan tampilkan pertumbuhan MoM untuk membandingkan bulan parsial dengan bulan penuh.

### Halaman 2 — Customer Analytics

**Tujuan:** memperlihatkan jumlah dan pola belanja pelanggan pada populasi order delivered.

- Kartu: Unique Customers, Repeat Customers, Repeat Purchase Rate, Median Customer Spend.
- Bar horizontal: jumlah pelanggan per `customer_rfm.rfm_segment`.
- Distribusi belanja pelanggan berdasarkan `customer_summary.product_spend`; gunakan bin/rentang yang diberi label jelas. Jangan mengklaim adanya kolom spend band di sumber.
- Tampilkan periode dan definisi customer berdasarkan `customer_unique_id`.

### Halaman 3 — Delivery & Reviews

**Tujuan:** menentukan wilayah dan kategori yang layak ditinjau berdasarkan rate dan volume, lalu membandingkan rating.

- Kartu: Average Delivery Days, Late Delivery Rate, Late Orders, Late Eligible Orders.
- Bar horizontal menurut negara bagian: `late_rate`, dengan `eligible_orders` dan `late_orders` sebagai konteks.
- Bar horizontal menurut kategori: `late_rate`; sertakan jumlah pesanan eligible. Satu pesanan dapat muncul pada beberapa kategori, jadi jumlah antar kategori tidak bersifat aditif.
- Grafik perbandingan: `review_by_delivery_status.delivery_status` terhadap `avg_review_score`; tampilkan jumlah `reviewed_orders`.
- Tampilkan low-rating rate jika denominator valid terlihat.
- Jangan mengurutkan wilayah hanya dari rate tanpa volume; pertahankan batas minimal 100 order eligible yang sudah diterapkan view.

## 5. Tampilan dan aksesibilitas

- Rasio halaman 16:9, grid rapi, jarak konsisten, judul grafik menyampaikan makna, bukan hanya nama kolom.
- Gunakan tema `powerbi_theme.json`: teal utama `#0F766E`, latar `#F3F7F8`, teks `#102B3F`.
- Format uang sebagai BRL (R$), persentase dengan `%`, hari dengan satuan hari, dan tanggal/bulan secara konsisten.
- Gunakan warna berbeda yang tetap terbaca untuk on-time dan late; jangan hanya mengandalkan warna untuk membedakan status.
- Hindari 3D, dekorasi berlebih, pie chart berkategori banyak, label bertumpuk, dan angka tanpa denominator.
- Cantumkan sumber Olist dan periode 2016–2018 serta catatan bahwa temuan bersifat historis.

## 6. Pemeriksaan hasil

Pastikan dashboard konsisten dengan query SQL dan populasi KPI. Hasil referensi proyek:

- Delivered orders: **96.478**.
- Product Sales: **R$13.221.498,11**; AOV: **R$137,04**; freight: **R$2.198.275,64**.
- Late rate: **7.826 / 96.470 = 8,11%**. Delapan order delivered tanpa tanggal aktual tidak masuk denominator.
- Average Delivery Days: **12,56**.
- Rating rata-rata: **2,57/5** untuk late (7.661 order review) dan **4,29/5** untuk on-time (88.163 order review).
- Repeat Purchase Rate: **2.801 / 93.358 = 3,00%**.

Jika angka berbeda, periksa filter status, denominator, jenis agregasi, dan relasi model sebelum mengubah query atau rumus.

## 7. Deliverable

- File Power BI native: `dashboard/ecommerce_dashboard.pbix`.
- Screenshot halaman dashboard: `images/dashboard_sales_overview.png`, `images/dashboard_customer_analytics.png`, dan `images/dashboard_delivery_reviews.png`.
- README proyek diperbarui dengan gambar preview, cara membuka laporan, sumber data, insight utama, dan keterbatasan.
- Tandai WP-08 pada `../docs/prd_status.md` selesai hanya setelah PBIX dan screenshot Power BI Desktop benar-benar tersedia. Preview gambar statis bukan pengganti screenshot tersebut.

Jika AI yang digunakan tidak dapat mengoperasikan Power BI Desktop, minta AI memberi instruksi klik demi klik dan DAX yang bisa disalin. Jangan menerima klaim bahwa PBIX sudah dibuat jika file tersebut tidak benar-benar tersedia.

---

## Prompt siap salin

```text
Buat dashboard Power BI profesional untuk proyek E-Commerce Sales & Delivery Performance Analytics.

Tujuan utama: jawab “Bagaimana ketepatan pengiriman berkaitan dengan kepuasan pelanggan, dan segmen operasional mana yang perlu diperiksa lebih dahulu?” Dataset Olist bersifat historis (2016–2018), jadi jangan menyatakan temuan sebagai kondisi bisnis saat ini atau hubungan sebab-akibat.

Sumber data sudah tersedia di PostgreSQL database olist_ecommerce_analytics, skema analytics. Saya akan memasukkan kredensial sendiri; jangan meminta, menulis, atau menyimpan password. Pakai mode Import. Gunakan view analytics yang diperlukan dari spesifikasi ini dan jangan memakai raw tables.

Ikuti grain setiap view. Jangan menghubungkan order_sales, order_delivery, dan tabel ringkasan secara sembarang atau membuat relasi many-to-many. Jangan menggandakan sales melalui join. Pakai definisi KPI dan DAX starter di dashboard/powerbi_measures.dax; periksa bahwa denominator dan filter statusnya sesuai definisi SQL sebelum dipakai. Jangan mengarang kolom atau hasil. Jika visual membutuhkan field/view yang belum tersedia, sebutkan kebutuhan itu dengan jelas.

Buat tiga halaman:
1. Sales Overview: Product Sales, Delivered Orders, AOV, Freight Charges, tren bulanan, 10 kategori teratas, dan sales per negara bagian.
2. Customer Analytics: pelanggan unik, pelanggan repeat, repeat rate, median spend, distribusi product_spend, dan jumlah pelanggan per segmen RFM.
3. Delivery & Reviews: durasi rata-rata, late rate beserta jumlah late dan eligible, late rate per state dan kategori beserta volume, rating rata-rata late vs on-time, serta low-rating rate.

Gunakan tema dashboard/powerbi_theme.json, layout 16:9 yang bersih, judul yang jelas, BRL untuk uang, satuan untuk semua KPI, dan warna yang aksesibel. Jangan membuat slicer global jika relasi tidak meneruskan filter dengan benar. Cantumkan rentang tanggal sumber, tandai bulan terakhir jika parsial, dan jangan membandingkan bulan parsial dengan bulan penuh. Cantumkan juga bahwa hasil observasional bukan bukti kausal. Salin measure dari file DAX satu per satu melalui Power BI; jangan menganggap file `.dax` bisa diimpor sebagai kumpulan measure.

Cocokkan hasil terhadap SQL: 96.478 delivered orders; Product Sales R$13.221.498,11; AOV R$137,04; late 7.826 dari 96.470 (8,11%); durasi rata-rata 12,56 hari; rating late 2,57/5 dan on-time 4,29/5; repeat rate 2.801 dari 93.358 (3,00%). Jika berbeda, jelaskan filter/denominator yang perlu diperiksa, jangan memaksa angka.

Simpan hasil sebagai dashboard/ecommerce_dashboard.pbix dan ekspor screenshot ke images/ dengan nama dashboard_sales_overview.png, dashboard_customer_analytics.png, dan dashboard_delivery_reviews.png. Jangan membuat versi Python atau HTML. Jika Anda tidak dapat menjalankan Power BI Desktop, jangan berpura-pura menghasilkan PBIX: berikan langkah klik demi klik, rumus DAX satu per satu, serta visual dan field yang harus dipasang.
```
