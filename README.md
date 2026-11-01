# E-Commerce Sales & Delivery Performance Analytics

Di proyek ini saya mengolah data publik Olist Brasil untuk melihat penjualan, kebiasaan belanja pelanggan, dan ketepatan pengiriman. Analisisnya memakai PostgreSQL dan SQL, lalu hasilnya disiapkan untuk divisualisasikan di Power BI. Data yang digunakan mencakup pesanan dari September 2016 sampai Oktober 2018.

## Pertanyaan yang saya bahas

Seberapa sering pesanan terlambat, bagaimana keterlambatan berkaitan dengan rating pelanggan, dan wilayah atau kategori mana yang layak ditinjau lebih dulu?

## Hasil utama

- Ada **96.478 pesanan terkirim**, dengan nilai penjualan produk **R$ 13.221.498,11** dan rata-rata nilai pesanan **R$ 137,04**.
- Tingkat keterlambatan **8,11%** (7.826 dari 96.470 pesanan dengan tanggal yang valid). Rata-rata waktu pengiriman **12,56 hari**.
- Rating pesanan terlambat rata-rata **2,57/5**, sedangkan pesanan tepat waktu **4,29/5**. Ini menunjukkan hubungan dalam data, bukan bukti bahwa keterlambatan menjadi penyebab rating turun.
- Tingkat pembelian ulang **3,00%** pada pelanggan yang memiliki setidaknya satu pesanan terkirim selama periode data.
- Total harga item sebelum dan sesudah pemodelan SQL cocok, dengan selisih **R$ 0,00**.

Nilai penjualan menghitung harga produk. Ongkos kirim ditampilkan terpisah; proyek ini tidak menghitung laba atau pendapatan bersih.

## Isi folder

| Folder | Isi |
|---|---|
| [`data/`](data/) | Sembilan CSV Olist, petunjuk sumber data, dan manifest ukuran serta checksum. |
| [`sql/`](sql/) | Skrip untuk membuat tabel, memuat data, memeriksa kualitas, membangun view, dan menghitung KPI. |
| [`dashboard/`](dashboard/) | Spesifikasi, measure DAX, tema, dan preview tiga halaman dashboard. |
| [`docs/`](docs/) | PRD, definisi KPI, panduan PostgreSQL dan Power BI, serta laporan analisis. |
| [`images/`](images/) | ERD dan tempat menyimpan screenshot Power BI setelah laporan selesai dibuat. |

## Cara menjalankan

1. Letakkan sembilan CSV Olist asli di `data/`. Nama dan jumlah barisnya tercatat di [manifest](data/dataset_manifest.csv). File CSV sumber tidak disertakan dalam Git.
2. Buat database `olist_ecommerce_analytics`, lalu ikuti [panduan PostgreSQL dan Power BI](docs/postgresql_powerbi_guide.md).
3. Jalankan skrip SQL berurutan dari `sql/01_setup/` sampai `sql/05_validation/`.
4. Untuk menyusun laporan Power BI, ikuti [spesifikasi dashboard](dashboard/PRD_Dashboard_PowerBI.md) dan lihat [preview visual](dashboard/README.md).

## Status dashboard

Tiga preview dashboard tersedia sebagai gambar statis. File Power BI interaktif (`dashboard/ecommerce_dashboard.pbix`) belum dibuat. Status dan pekerjaan yang masih tersisa tercatat di [matriks PRD](docs/prd_status.md). Kredensial PostgreSQL dimasukkan langsung di aplikasi dan tidak disimpan dalam proyek.

## Dokumen utama

[PRD proyek](docs/PRD_Ecommerce_Sales_Delivery_Performance_Analytics.md) | [metodologi dan KPI](docs/methodology.md) | [kamus data](docs/data_dictionary.md) | [laporan kualitas](docs/data_quality_report.md) | [temuan dan rekomendasi](docs/business_insights.md) | [ringkasan eksekutif](docs/executive_summary.pdf) | [ERD](images/erd.png)
