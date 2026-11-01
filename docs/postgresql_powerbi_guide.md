# Menyiapkan PostgreSQL dan Power BI

Panduan ini menjelaskan cara memuat CSV Olist ke PostgreSQL dan memakai view analitiknya di Power BI Desktop. Langkah disusun untuk Windows; jalankan perintah dari folder utama proyek.

## 1. Siapkan file CSV

Unduh dataset Olist dari [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), ekstrak, lalu letakkan sembilan CSV asli di folder `data/`. Nama berkasnya tercantum di [petunjuk data](../data/README.md). Jangan mengubah isi sumber.

## 2. Buat database PostgreSQL

Pasang PostgreSQL untuk Windows dari [situs resmi PostgreSQL](https://www.postgresql.org/download/windows/). Saat instalasi, gunakan port `5432` jika belum dipakai dan simpan kata sandi pengguna `postgres` di tempat yang aman.

Di pgAdmin, buat database dengan nama berikut:

```text
olist_ecommerce_analytics
```

Atau jalankan dari PowerShell:

```powershell
createdb -U postgres olist_ecommerce_analytics
```

Jika `createdb` atau `psql` tidak dikenali, tambahkan folder `bin` PostgreSQL ke PATH PowerShell. Contoh jika PostgreSQL terpasang di versi 18:

```powershell
$env:Path += ';C:\Program Files\PostgreSQL\18\bin'
```

Database lokal proyek ini terakhir diperiksa pada 29 Oktober 2026. Kredensial tidak disimpan di dalam folder proyek.

## 3. Buat tabel dan muat data

Buka PowerShell di folder utama proyek dan pastikan kesembilan CSV tersedia di `data/`. Untuk pemuatan awal, jalankan:

```powershell
psql -U postgres -d olist_ecommerce_analytics -f sql/01_setup/create_schemas.sql
psql -U postgres -d olist_ecommerce_analytics -f sql/01_setup/create_tables.sql
psql -U postgres -d olist_ecommerce_analytics -f sql/01_setup/load_csvs.psql
```

Loader memakai `\copy`, membaca file dari komputer Anda, dan menambahkan baris ke tabel. Untuk memuat ulang dari awal, kosongkan tabel raw terlebih dahulu. **Perintah berikut menghapus seluruh isi sembilan tabel raw di database tersebut; jalankan hanya jika memang ingin mengganti pemuatan yang ada.**

```powershell
psql -U postgres -d olist_ecommerce_analytics -c "TRUNCATE TABLE raw.olist_customers_dataset, raw.olist_orders_dataset, raw.olist_order_items_dataset, raw.olist_order_payments_dataset, raw.olist_order_reviews_dataset, raw.olist_products_dataset, raw.olist_sellers_dataset, raw.olist_geolocation_dataset, raw.product_category_name_translation;"
```

Setelah tabel dikosongkan, jalankan lagi perintah pembuatan tabel dan loader di atas. Masukkan kata sandi PostgreSQL saat diminta. Jangan jalankan loader berulang tanpa mengosongkan tabel karena baris akan bertambah lagi.

## 4. Periksa data dan buat view analitik

Jalankan pemeriksaan, buat view, lalu cek rekonsiliasi KPI:

```powershell
psql -U postgres -d olist_ecommerce_analytics -f sql/02_quality/data_profiling.sql
psql -U postgres -d olist_ecommerce_analytics -f sql/02_quality/data_quality_checks.sql
psql -U postgres -d olist_ecommerce_analytics -f sql/03_modeling/analytical_views.sql
psql -U postgres -d olist_ecommerce_analytics -f sql/05_validation/kpi_validation.sql
```

Pada hasil validasi, jumlah baris view tingkat pesanan harus sama dengan jumlah `order_id` unik, query pelanggaran grain seharusnya tidak mengembalikan baris, dan selisih total harga item harus nol.

Untuk menjalankan analisis penjualan, pelanggan, dan pengiriman:

```powershell
psql -U postgres -d olist_ecommerce_analytics -f sql/04_analysis/sales_analysis.sql
psql -U postgres -d olist_ecommerce_analytics -f sql/04_analysis/customer_analysis.sql
psql -U postgres -d olist_ecommerce_analytics -f sql/04_analysis/delivery_analysis.sql
```

## 5. Hubungkan Power BI Desktop

1. Pilih **Home > Get data > PostgreSQL database**.
2. Isi server `localhost:5432` dan database `olist_ecommerce_analytics`.
3. Pilih **Import**. Untuk dataset portofolio ini, Power BI akan memuat salinan data dan memperbaruinya saat Anda memilih refresh.
4. Di jendela kredensial, pilih **Database**, lalu isi nama pengguna dan kata sandi PostgreSQL. Pada instalasi lokal, nama penggunanya biasanya `postgres`.
5. Di Navigator, pilih view yang diperlukan dari skema `analytics`: `order_sales`, `order_delivery`, `customer_summary`, `customer_rfm`, `product_category_sales`, `monthly_sales`, `sales_by_state`, `delivery_by_state`, `delivery_by_category`, dan `review_by_delivery_status`.
6. Gunakan [starter DAX](../dashboard/powerbi_measures.dax) untuk membuat measure satu per satu. Power BI tidak memuat seluruh measure dari file `.dax` sekaligus. Jika memakai tabel kalender, buat tabel `Calendar` dari DAX dan hubungkan `Calendar[Date]` ke `order_sales[purchase_date]`.
7. Jangan menghubungkan view tingkat pesanan dan view ringkasan secara sembarang. Grain tabelnya berbeda, dan relasi yang keliru dapat menggandakan nilai KPI. Gunakan view ringkasan langsung pada visual yang sesuai.
8. Muat tema dari menu **View > Themes**, lalu susun halaman dengan mengikuti [spesifikasi dashboard](../dashboard/PRD_Dashboard_PowerBI.md). Simpan laporan sebagai `dashboard/ecommerce_dashboard.pbix`; simpan screenshot halaman di `images/`.

## Jika muncul pesan koneksi terenkripsi

Jika PostgreSQL dan Power BI Desktop berjalan di komputer yang sama (`localhost`) dan koneksi gagal karena enkripsi, hilangkan centang **Use encrypted connection** lalu coba sambungkan lagi. Jika muncul konfirmasi untuk melanjutkan tanpa enkripsi, pilih **OK/Continue**. Pengaturan ini hanya untuk koneksi lokal ketika PostgreSQL belum dikonfigurasi dengan SSL.

Jangan memakai koneksi tanpa enkripsi ke server komputer lain atau melalui jaringan. Untuk server jarak jauh, gunakan SSL dan pastikan sertifikat server dipercaya Windows. Lihat panduan resmi [konektor PostgreSQL untuk Power Query](https://learn.microsoft.com/en-us/power-query/connectors/postgresql).

## Catatan model laporan

`order_sales` dan `order_delivery` masing-masing memiliki satu baris per pesanan. Hindari relasi yang menggandakan ukuran penjualan atau pengiriman. `customer_summary` dan `customer_rfm` memiliki satu baris per identitas pelanggan, sedangkan `monthly_sales`, `product_category_sales`, dan view ringkasan keterlambatan sudah diagregasi sesuai kebutuhan visual.

Untuk tiga halaman laporan, gunakan [PRD dashboard](../dashboard/PRD_Dashboard_PowerBI.md) sebagai acuan:

- **Ringkasan Penjualan:** penjualan produk, pesanan terkirim, AOV, tren bulanan, kategori, dan negara bagian pelanggan.
- **Analisis Pelanggan:** pelanggan unik, pembelian ulang, sebaran pengeluaran, dan segmen RFM.
- **Pengiriman dan Ulasan:** durasi pengiriman, keterlambatan beserta jumlah pesanan, perbandingan wilayah/kategori, dan rating.

Jika visual membutuhkan hasil yang belum tersedia dalam view, buat view SQL dengan grain yang jelas. Hindari menggabungkan tabel mentah satu-ke-banyak langsung di Power BI.

## Opsional: publikasi ke Power BI Service

Untuk memperbarui laporan Power BI Service dari PostgreSQL yang berjalan lokal, biasanya diperlukan on-premises data gateway. Jangan membuka akses database lokal langsung ke internet. Baca [persyaratan konektor PostgreSQL Microsoft](https://learn.microsoft.com/en-us/power-query/connectors/postgresql) sebelum menyiapkan refresh daring.
