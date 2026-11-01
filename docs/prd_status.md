# Status pemenuhan PRD

Rujukan: [PRD proyek](PRD_Ecommerce_Sales_Delivery_Performance_Analytics.md). Pemeriksaan mengacu pada sembilan CSV, hasil pemuatan PostgreSQL lokal, dan query analisis yang ada di proyek.

| Paket kerja | Bukti | Status | Catatan |
|---|---|---|---|
| WP-01 Penyiapan database dan pemahaman data | Skema PostgreSQL, sembilan tabel sumber, 13 view, ERD, kamus data, manifest | **Selesai** | Jumlah baris hasil pemuatan cocok dengan file sumber. |
| WP-02 Pemeriksaan kualitas data | Pemeriksaan key, nilai kosong, rentang nilai, tanggal, relasi, dan cakupan KPI | **Selesai** | Temuan yang memengaruhi KPI dicatat; baris sumber tetap utuh. |
| WP-03 Model analitik | View tingkat pesanan serta ringkasan kategori, pelanggan, penjualan, pengiriman, dan ulasan | **Selesai** | 99.441 pesanan; tidak ada `order_id` ganda pada view tingkat pesanan. |
| WP-04 Analisis penjualan | Query penjualan, AOV, tren, kategori, dan wilayah | **Selesai** | Total harga item cocok dengan model; selisih R$ 0. |
| WP-05 Analisis pelanggan | Pembelian ulang, kelompok belanja, frekuensi, dan RFM | **Selesai** | Definisi serta query tersedia di folder analisis SQL. |
| WP-06 Pengiriman dan kepuasan | Durasi, keterlambatan, wilayah/kategori, serta rating | **Selesai** | Denominator dijelaskan; hubungan data tidak dinyatakan sebagai sebab-akibat. |
| WP-07 Validasi KPI | Pemeriksaan tingkat rincian, key ganda, rekonsiliasi penjualan, dan cakupan data | **Selesai** | Satu pesanan tanpa pembayaran dan delapan tanpa tanggal tiba dicatat. |
| WP-08 Dashboard Power BI | View analitik, DAX, tema, panduan, dan tiga preview visual | **Sebagian** | File `.pbix` dan screenshot asli Power BI masih perlu dibuat. |
| WP-09 Temuan dan dokumentasi | README, rekomendasi, ringkasan eksekutif, laporan kualitas, dan metodologi | **Selesai** | Angka utama dapat ditelusuri ke query SQL. |

## Sisa pekerjaan

Bagian analisis SQL, validasi, dan dokumentasi sudah tersedia. Tiga preview statis untuk halaman Ringkasan Penjualan, Analisis Pelanggan, serta Pengiriman dan Ulasan ada di `dashboard/visualizations/`. Preview ini belum interaktif dan bukan screenshot Power BI. File laporan `.pbix` dan screenshot dari Power BI Desktop masih perlu dibuat di aplikasi tersebut.

PRD juga merekomendasikan publikasi melalui GitHub. Proyek ini belum terhubung ke repositori GitHub. Jika ingin mempublikasikannya, tentukan repositori tujuan dan pastikan file CSV sumber serta kredensial tetap dikecualikan.
