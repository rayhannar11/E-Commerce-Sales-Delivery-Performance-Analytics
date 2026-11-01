# E-Commerce Sales & Delivery Performance Analytics

*Dokumen kebutuhan proyek (PRD)*

| Informasi | Detail |
|---|---|
| **Jenis proyek** | Portofolio analisis data menyeluruh |
| **Industri** | Perdagangan daring / ritel |
| **Peran** | Analis data junior (simulasi kasus bisnis) |
| **Prioritas teknologi** | PostgreSQL, SQL, Power BI |
| **Tingkat kesulitan** | Menengah |
| **Estimasi pengerjaan** | 3 minggu (fleksibel) |
| **Status dokumen** | Versi 1.0, diselaraskan dengan implementasi proyek |
| **Dataset** | Olist Brazilian E-Commerce Public Dataset (data historis 2016–2018) |

> **Catatan:** Ini adalah simulasi kebutuhan analitik untuk portofolio, bukan proyek resmi atau penugasan dari Olist. Dataset bersifat historis dan dianonimkan; temuan tidak boleh diklaim mencerminkan kondisi bisnis saat ini.

## 1. Ringkasan Eksekutif

Dalam proyek ini, data Olist diolah dengan SQL untuk melihat kinerja penjualan, kebiasaan pelanggan, dan ketepatan pengiriman. Hasilnya disajikan dalam **view analitik**, pemeriksaan KPI, **dashboard Power BI**, serta rekomendasi yang bisa ditelusuri kembali ke query.

**Pertanyaan utama:** Bagaimana ketepatan pengiriman berkaitan dengan kepuasan pelanggan, dan wilayah atau kategori mana yang perlu ditinjau lebih dahulu?

Analisis penjualan dan pelanggan digunakan sebagai konteks pendukung, bukan menggantikan fokus operasional.

## 2. Latar Belakang dan Masalah Bisnis

Data operasional tersebar dalam tabel pesanan, item, pelanggan, pembayaran, produk, penjual, dan ulasan. Jika langsung digabung tanpa memperhatikan tingkat rinciannya, metrik seperti nilai penjualan dan jumlah pesanan berisiko terduplikasi. Manajemen membutuhkan definisi KPI yang konsisten serta laporan untuk:

1. Memantau tren nilai transaksi dan jumlah pesanan.
2. Mengidentifikasi kategori produk serta wilayah berkontribusi tinggi.
3. Memahami proporsi pelanggan yang kembali membeli.
4. Mengukur ketepatan pengiriman dan hubungannya dengan rating pelanggan.
5. Menentukan prioritas investigasi operasional berdasarkan volume dan tingkat masalah.

## 3. Tujuan dan Indikator Keberhasilan

| ID | Tujuan | Indikator keberhasilan |
|---|---|---|
| OBJ-01 | Menyediakan basis data analitik yang konsisten | Tabel sumber, relasi, grain, dan aturan transformasi terdokumentasi |
| OBJ-02 | Menjamin keandalan metrik | Pemeriksaan duplikasi, null, tanggal, dan rekonsiliasi agregasi lulus |
| OBJ-03 | Menjawab pertanyaan bisnis | Seluruh pertanyaan prioritas memiliki SQL, hasil, dan interpretasi |
| OBJ-04 | Menyediakan pelaporan interaktif | Dashboard 3 halaman dengan filter dan angka yang konsisten dengan SQL |
| OBJ-05 | Menghasilkan rekomendasi | Minimal 3 rekomendasi berbasis bukti, disertai keterbatasan analisis |

## 4. Ruang Lingkup

### Termasuk dalam proyek
- Memuat dataset ke PostgreSQL dengan skema `raw`.
- Profiling, pemeriksaan kualitas data, dan dokumentasi penanganan anomali.
- Membuat skema `analytics` berisi view dengan tingkat rincian yang jelas.
- Analisis penjualan, pelanggan, pengiriman, dan ulasan.
- Dashboard Power BI dan ringkasan temuan untuk pemangku kepentingan.
- Panduan agar proyek dapat dijalankan ulang melalui README dan skrip SQL berurutan.

### Di luar cakupan
- Model machine learning atau prediksi keterlambatan.
- Analisis profit, margin, biaya logistik aktual, atau atribusi kausal.
- Dashboard real-time atau koneksi ke sistem produksi.
- Pengumpulan data pribadi pelanggan maupun enrichment eksternal yang tidak tervalidasi.

## 5. Sumber Data

**Dataset:** Olist Brazilian E-Commerce Public Dataset

**Sumber:** https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

| Tabel sumber | Grain / kegunaan utama |
|---|---|
| `olist_orders_dataset` | Satu baris per `order_id`; status dan timestamp pesanan |
| `olist_order_items_dataset` | Satu baris per item pesanan (`order_id`, `order_item_id`); harga dan ongkir |
| `olist_customers_dataset` | Identitas rekaman pelanggan dan `customer_unique_id` |
| `olist_products_dataset` | Atribut produk dan kategori |
| `olist_order_payments_dataset` | Satu baris per urutan pembayaran per pesanan |
| `olist_order_reviews_dataset` | Ulasan; kemungkinan lebih dari satu baris per pesanan |
| `olist_sellers_dataset` | Identitas dan wilayah seller |
| `olist_geolocation_dataset` | Beberapa baris per kode pos; **jangan join mentah langsung ke fakta transaksi** |
| `product_category_name_translation` | Padanan nama kategori |

**Kunci penting:** `customer_id` merepresentasikan rekaman pelanggan pada pesanan, sedangkan `customer_unique_id` digunakan untuk analisis pelanggan lintas pesanan. Audit ketidaklengkapan dan ketidakkonsistenan relasi dilakukan sebelum analisis.

## 6. Pengguna Laporan

| Pengguna dalam simulasi | Kebutuhan |
|---|---|
| Manajer bisnis / penjualan | Tren penjualan, kategori, wilayah |
| Manajer operasional | Ketepatan pengiriman, wilayah berisiko |
| Tim pengalaman pelanggan | Rating dan kaitannya dengan ketepatan pengiriman |
| Analis data | Query teruji, definisi KPI, dokumentasi dan dashboard |

## 7. Arsitektur Analitik dan Aturan Grain

```text
CSV sumber -> skema raw -> view analytics -> analisis dan validasi SQL -> dashboard Power BI
```

### Aturan pengolahan data
1. Agregasikan item ke **satu baris per order** sebelum menggabungkan data pembayaran atau review.
2. Agregasikan pembayaran per order secara terpisah; nilai pembayaran tidak otomatis sama dengan *product sales*.
3. Untuk ulasan dengan beberapa baris per order, tetapkan dan dokumentasikan satu strategi deduplikasi/representasi; laporkan jumlah kasusnya.
4. Hindari menggabungkan `geolocation` langsung pada zip code tanpa mereduksi menjadi satu baris per key.
5. Simpan tabel sumber apa adanya; lakukan perbaikan melalui view/transformasi terdokumentasi.
6. Jangan mencampurkan grain **item**, **order**, dan **customer** dalam satu agregasi tanpa kontrol.

## 8. Definisi KPI

| KPI | Definisi | Tingkat rincian / populasi |
|---|---|---|
| Delivered Orders | `COUNT(DISTINCT order_id)` untuk status `delivered` | Order |
| Product Sales | `SUM(price)` dari item yang terkait pesanan `delivered` | Item → Order |
| Freight Charges | `SUM(freight_value)` dari item pesanan `delivered` | Item → Order |
| Gross Order Value | Product Sales + Freight Charges; **bukan laba/pendapatan bersih** | Order |
| Average Order Value (AOV) | Total Product Sales / jumlah delivered orders yang valid dalam populasi analisis | Order |
| Monthly Sales | Product Sales menurut bulan `order_purchase_timestamp` | Order |
| MoM Growth | `(sales_t / sales_t-1) - 1`; NULL bila bulan pembanding tidak tersedia atau nol | Bulan |
| Repeat Purchase Rate | Pelanggan unik dengan ≥2 pesanan valid / seluruh pelanggan unik dengan ≥1 pesanan valid | Customer |
| Delivery Time | Selisih `order_delivered_customer_date` dan `order_purchase_timestamp` dalam hari | Delivered order dengan tanggal valid |
| Late Delivery Rate | Jumlah pesanan dengan `delivered_date > estimated_delivery_date` / jumlah pesanan yang memiliki kedua tanggal valid | Delivered order |
| Average Review Score | Rata-rata rating dari representasi ulasan yang telah ditetapkan | Order dengan review valid |
| Low Rating Rate | Proporsi pesanan ber-review valid dengan skor ≤2 | Order dengan review valid |

**Aturan tambahan:** Tentukan cutoff tanggal analisis dan perlakuan periode parsial. Untuk membandingkan wilayah, tampilkan jumlah pesanan dan gunakan ambang volume minimum yang dinyatakan eksplisit. *Late delivery* berarti melewati **tanggal estimasi**, bukan selalu melanggar SLA kontraktual.

## 9. Kebutuhan Fungsional dan Paket Pekerjaan

### WP-01 : Penyiapan Database dan Pemahaman Data

**Tugas:**
- Buat database `olist_ecommerce_analytics`, skema `raw` dan `analytics`.
- Impor sembilan CSV; tetapkan tipe data, PK/FK yang sesuai dengan hasil audit.
- Buat ERD dan data dictionary.
- Catat jumlah baris dan rentang tanggal setiap tabel.

**Hasil:** `sql/01_setup/`, `images/erd.png`, `docs/data_dictionary.md`.

**Kriteria keberhasilan:** Seluruh sumber dapat diimpor ulang dengan instruksi README; jumlah baris setelah pemuatan sama dengan sumber.

### WP-02 : Profil dan Kualitas Data

**Pemeriksaan:** nilai kosong, key ganda, kecocokan relasi antartabel, nilai negatif atau tidak wajar, urutan tanggal, data pengiriman/ulasan yang kosong, serta ketidaksesuaian jumlah pesanan dan item.

**Hasil:** `sql/02_quality/`, `docs/data_quality_report.md`.

**Kriteria keberhasilan:** Setiap isu memiliki jumlah kasus, keputusan penanganan, dan dampak terhadap KPI; tidak ada penghapusan baris sumber tanpa dokumentasi.

### WP-03 : Pemodelan Data Analitik

**Tugas:**
- Bangun `analytics.order_sales` dari agregasi item per pesanan.
- Bangun `analytics.order_delivery` dengan status, estimasi, tanggal aktual, dan indikator terlambat.
- Bangun `analytics.customer_summary` berdasarkan `customer_unique_id`.
- Bangun agregasi kategori produk untuk dashboard.
- Audit keunikan `order_id` pada order-level views.

**Hasil:** `sql/03_modeling/`.

**Kriteria keberhasilan:** Satu baris per key yang didefinisikan; total item sales sebelum dan setelah modeling konsisten pada populasi sama.

### WP-04 : Analisis Kinerja Penjualan

| ID | Pertanyaan bisnis | Teknik SQL |
|---|---|---|
| SA-01 | Berapa total penjualan produk dan jumlah pesanan terkirim? | SUM, COUNT DISTINCT |
| SA-02 | Berapa rata-rata nilai pesanan (AOV)? | CTE, agregasi |
| SA-03 | Bagaimana tren penjualan bulanan dan perubahannya dari bulan sebelumnya? | DATE_TRUNC, LAG |
| SA-04 | Apa 10 kategori produk teratas? | JOIN, RANK |
| SA-05 | Wilayah pelanggan mana yang berkontribusi terbesar? | JOIN, GROUP BY |

**Hasil:** `sql/04_analysis/sales_analysis.sql`.

### WP-05 : Analisis Perilaku Pelanggan

| ID | Pertanyaan bisnis | Teknik SQL |
|---|---|---|
| CA-01 | Berapa jumlah pelanggan unik? | COUNT DISTINCT |
| CA-02 | Berapa tingkat pembelian ulang pelanggan? | CTE, HAVING |
| CA-03 | Bagaimana sebaran belanja pelanggan? | SUM, percentile opsional |
| CA-04 | Bagaimana hasil segmentasi RFM? | DATE arithmetic, NTILE |

**Ketentuan:** Tentukan definisi pesanan valid dan tanggal referensi RFM; jangan menggunakan `customer_id` sebagai pelanggan lintas pesanan.

**Hasil:** `sql/04_analysis/customer_analysis.sql`.

### WP-06 : Analisis Pengiriman dan Kepuasan (Prioritas Utama)

| ID | Pertanyaan bisnis | Teknik SQL |
|---|---|---|
| DA-01 | Berapa rata-rata durasi pengiriman? | EXTRACT(EPOCH), AVG |
| DA-02 | Berapa tingkat keterlambatan pengiriman secara keseluruhan? | CASE, AVG / SUM |
| DA-03 | Wilayah mana yang paling bermasalah dengan mempertimbangkan volume? | GROUP BY, HAVING |
| DA-04 | Bagaimana tingkat keterlambatan menurut kategori produk? | JOIN, CTE |
| DA-05 | Bagaimana perbedaan rata-rata rating antara pesanan tepat waktu dan terlambat? | Conditional aggregation |
| DA-06 | Apakah proporsi rating rendah lebih tinggi pada pesanan terlambat? | CASE, CTE |

**Hasil:** `sql/04_analysis/delivery_analysis.sql`.

**Interpretasi wajib:** Jelaskan potensi faktor perancu (wilayah, kategori, periode) dan keterbatasan data observasional. Hindari klaim sebab-akibat.

### WP-07 : Validasi KPI dan Kualitas SQL

- Bandingkan jumlah `order_id` unik pada raw dan analytical views.
- Rekonsiliasi product sales dari item-level terhadap order-level.
- Pastikan join review/payment tidak menggandakan nilai penjualan.
- Audit denominator KPI dan pengecualian missing dates.
- Simpan query validasi beserta expected checks.

**Hasil:** `sql/05_validation/kpi_validation.sql`.

### WP-08 : Dashboard Power BI

**Halaman 1: Sales Overview** — Product Sales, Delivered Orders, AOV, tren bulanan, kategori, wilayah.

**Halaman 2: Customer Analytics** — Unique Customers, Repeat Purchase Rate, distribusi spending, segmen RFM.

**Halaman 3: Delivery & Reviews** — Average Delivery Time, Late Delivery Rate, keterlambatan per wilayah, rating menurut status pengiriman, Low Rating Rate.

**Kebutuhan UX:** judul jelas, satuan metrik, periode analisis, filter yang relevan, label definisi KPI, dan grafik yang tidak menyesatkan. Gunakan output SQL sebagai sumber utama.

**Hasil:** `dashboard/ecommerce_dashboard.pbix` dan screenshot Power BI Desktop di `images/`. Mockup statis di `dashboard/visualizations/` membantu merancang halaman, tetapi tidak menggantikan PBIX atau screenshot hasil Power BI.

### WP-09 : Temuan, Rekomendasi, dan Dokumentasi

Tulis ringkasan maksimal 2 halaman berisi: konteks, 3–5 temuan numerik, dampak bisnis, rekomendasi prioritas, dan keterbatasan. Setiap angka harus dapat ditelusuri ke query/dashboard.

**Hasil:** `docs/business_insights.md`, `docs/executive_summary.pdf`, `README.md`.

## 10. Kebutuhan Nonfungsional

- **Reproducibility:** seluruh SQL berurutan, data source dan langkah import terdokumentasi.
- **Traceability:** KPI dapat dilacak ke definisi dan query pembentuknya.
- **Data integrity:** tabel `raw` tidak ditimpa; pembersihan dilakukan terpisah.
- **Readability:** query memakai nama alias jelas, CTE seperlunya, komentar untuk aturan bisnis.
- **Performance:** indeks hanya ditambahkan bila relevan; `EXPLAIN ANALYZE` untuk query lambat (opsional).
- **Ethics:** jangan mengklaim hubungan kausal, profit, atau data terkini tanpa dasar.

## 11. Rekomendasi Tools

### Stack inti — paling disarankan

| Tool | Fungsi | Prioritas | Alasan untuk portofolio |
|---|---|---|---|
| **PostgreSQL** | Database relasional dan SQL utama | Wajib | Menunjukkan kompetensi SQL praktis |
| **DBeaver Community** | SQL editor, inspeksi tabel, query development | Wajib (atau pgAdmin) | Memudahkan eksplorasi dan pengujian query |
| **Power BI Desktop** | Dashboard interaktif | Wajib untuk versi lengkap | Menunjukkan kemampuan BI dan komunikasi KPI |
| **Git + GitHub** | Version control dan publikasi | Wajib | Menunjukkan struktur kerja, riwayat perubahan, dan dokumentasi |
| **VS Code** | Edit SQL/Markdown dan organisasi repo | Disarankan | Workflow pengembangan yang rapi |
| **dbdiagram.io** | ERD dan relasi tabel | Disarankan | Memperjelas desain dan grain database |

### Tool tambahan — hanya jika memberi nilai nyata

| Tool | Fungsi | Kapan dipakai |
|---|---|---|
| **Python + pandas** | Verifikasi import atau pengecekan tambahan | Bila ada kebutuhan yang sulit/kurang praktis di SQL; jangan menggantikan analisis SQL |
| **Docker Compose** | Menjalankan PostgreSQL secara konsisten | Jika ingin setup mudah direproduksi reviewer |
| **SQLFluff** | Linting dan konsistensi format SQL | Saat query mulai banyak |
| **Excel** | Cross-check KPI sederhana | Untuk validasi atau laporan pendamping, bukan sumber perhitungan utama |

**Pilihan praktis:** PostgreSQL + DBeaver + Power BI + GitHub + VS Code + dbdiagram.io. Tidak perlu menambahkan machine learning, Airflow, Spark, atau cloud warehouse hanya demi terlihat kompleks.

**Tautan resmi:**
- PostgreSQL: https://www.postgresql.org/
- DBeaver: https://dbeaver.io/
- Power BI: https://www.microsoft.com/en-us/power-platform/products/power-bi
- Git: https://git-scm.com/
- GitHub: https://github.com/
- VS Code: https://code.visualstudio.com/
- dbdiagram: https://dbdiagram.io/
- Docker: https://www.docker.com/
- SQLFluff: https://sqlfluff.com/

## 12. Struktur Proyek

Folder proyek saat ini disusun sebagai berikut:

```text
E-Commerce Sales & Delivery Performance Analytics/
|-- README.md
|-- .gitignore
|-- data/
|   |-- README.md
|   `-- dataset_manifest.csv
|-- sql/
|   |-- 01_setup/
|   |-- 02_quality/
|   |-- 03_modeling/
|   |-- 04_analysis/
|   `-- 05_validation/
|-- dashboard/
|   |-- README.md
|   |-- PRD_Dashboard_PowerBI.md
|   |-- powerbi_measures.dax
|   |-- powerbi_theme.json
|   `-- visualizations/
|-- docs/
|   |-- PRD_Ecommerce_Sales_Delivery_Performance_Analytics.md
|   |-- prd_status.md
|   |-- data_dictionary.md
|   |-- methodology.md
|   |-- postgresql_powerbi_guide.md
|   |-- data_quality_report.md
|   |-- business_insights.md
|   `-- executive_summary.pdf
`-- images/
    `-- erd.png
```

**Aturan repository:** Jangan unggah kredensial atau file berukuran besar tanpa kebutuhan. Dokumentasikan versi tool, sumber dataset, langkah menjalankan query, definisi KPI, dan batasan analisis.

## 13. Timeline dan Milestone

| Periode | Fokus | Milestone |
|---|---|---|
| Minggu 1 | Setup, ERD, profiling, quality checks | M1: Database siap dan audit kualitas selesai |
| Minggu 2 | Analytical views, sales/customer/delivery SQL, validasi | M2: KPI teruji dan pertanyaan bisnis terjawab |
| Minggu 3 | Dashboard, insight, dokumentasi, final review | M3: Portfolio siap dipublikasikan |

## 14. Kriteria Proyek Selesai

Proyek dianggap selesai jika seluruh kondisi berikut terpenuhi:

- [ ] Sembilan tabel sumber berhasil dimuat dan jumlah baris cocok.
- [ ] ERD, data dictionary, dan aturan grain terdokumentasi.
- [ ] Temuan data quality dan keputusan penanganannya tercatat.
- [ ] Analytical views bebas duplikasi key pada grain yang ditentukan.
- [ ] Seluruh pertanyaan bisnis prioritas dijawab dengan SQL.
- [ ] Product Sales dan jumlah pesanan direkonsiliasi antar-lapisan.
- [ ] Definisi dan denominator KPI konsisten.
- [ ] Dashboard memiliki tiga halaman dan sesuai hasil SQL.
- [ ] Minimal tiga rekomendasi memiliki bukti numerik.
- [ ] README menjelaskan tujuan, dataset, cara menjalankan, screenshot, insight, dan keterbatasan.
- [ ] Tidak ada klaim hasil yang belum dihitung atau klaim kausal tanpa pembuktian.

## 15. Risiko dan Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Join one-to-many menggandakan nilai sales | KPI salah | Agregasi pada grain order, validasi totals |
| Tanggal delivery/review kosong | Denominator bias | Definisikan populasi valid dan laporkan missingness |
| Data historis tidak mencerminkan kondisi sekarang | Interpretasi menyesatkan | Cantumkan periode dan batasan |
| Periode parsial memengaruhi MoM | Tren salah tafsir | Filter bulan lengkap atau beri penanda |
| Segmen kecil tampak memiliki late rate ekstrem | Rekomendasi tidak stabil | Tampilkan volume dan threshold minimum |
| Scope terlalu luas | Proyek tidak selesai | Prioritaskan delivery analysis, KPI, dan dashboard inti |

## 16. Kriteria Kualitas Portofolio

Reviewer seharusnya dapat memahami dalam 3–5 menit: **masalah bisnis → sumber data → metode SQL → KPI teruji → insight → rekomendasi**. README harus menampilkan 1 screenshot dashboard utama dan 3 temuan terpenting setelah proyek selesai. Riwayat commit harus mencerminkan progres nyata; jangan membuat hasil analisis atau angka fiktif.

---

**Nama repository yang direkomendasikan:** `ecommerce-sales-delivery-sql-analytics`

**Judul tampilan portofolio:** *E-Commerce Sales & Delivery Performance Analytics | PostgreSQL & Power BI*
