# Metodologi dan definisi KPI

## Populasi dan tingkat rincian

- Kesembilan CSV diperiksa tanpa mengubah atau menghapus baris pada skema `raw`.
- Tabel pelanggan, pesanan, item, pembayaran, produk, dan penjual diperiksa berdasarkan key kandidatnya. Tabel geolokasi memiliki beberapa titik untuk satu prefix, jadi tidak digabung langsung ke data transaksi.
- `order_items`, `order_payments`, dan `order_reviews` diringkas per `order_id` sebelum digabung ke pesanan. View `analytics.order_sales` dan `analytics.order_delivery` mempertahankan satu baris per pesanan.
- `review_id` digunakan ulang antar pesanan; key gabungan `(order_id, review_id)` diuji keunikannya. Baris ulasan tidak dibuang.

## Definisi

| Metrik | Definisi pada proyek |
|---|---|
| Pesanan terkirim | Jumlah `order_id` unik dengan `order_status = 'delivered'` |
| Penjualan produk | Total `price` item pada pesanan terkirim; ongkos kirim tidak termasuk |
| Ongkos kirim | Total `freight_value` item pada pesanan terkirim, dilaporkan terpisah |
| Rata-rata nilai pesanan (AOV) | Penjualan produk dibagi jumlah pesanan terkirim dengan nilai item yang tersedia |
| Penjualan bulanan | Penjualan produk dikelompokkan menurut bulan `order_purchase_timestamp` |
| Perubahan dari bulan sebelumnya (MoM) | `(sales bulan ini / sales bulan kalender sebelumnya) - 1`; null jika bulan sebelumnya tidak ada atau bernilai nol |
| Tingkat pembelian ulang | Pelanggan (`customer_unique_id`) dengan setidaknya dua pesanan terkirim dibagi pelanggan dengan setidaknya satu pesanan terkirim |
| Durasi pengiriman | Hari dari `order_purchase_timestamp` sampai `order_delivered_customer_date`; tanggal valid dan durasi tidak negatif |
| Tingkat keterlambatan | Pesanan terkirim yang tiba setelah tanggal estimasi dibagi pesanan terkirim dengan kedua tanggal valid |
| Rating ulasan | Skor valid dirata-ratakan per pesanan; 547 pesanan memiliki beberapa baris ulasan |
| Persentase rating rendah | Persentase pesanan dengan rata-rata skor valid 2 atau lebih rendah pada populasi ulasan terkait |
| RFM | Snapshot satu hari setelah pesanan terkirim terakhir; `NTILE(5)` untuk recency, frequency, dan monetary, dengan `customer_unique_id` sebagai pemecah nilai seri |

Kategori keterlambatan dan negara bagian ditampilkan hanya jika memiliki setidaknya 100 pesanan yang memenuhi syarat. Grafik persentase tetap menampilkan jumlah pesanan agar pembaca bisa mempertimbangkan volumenya. Satu pesanan dapat memuat beberapa kategori, sehingga hitungan antar kategori tidak bisa dijumlahkan sebagai total pesanan unik.

## Penanganan temuan kualitas

- Delapan pesanan terkirim tanpa tanggal aktual dikeluarkan dari perhitungan durasi dan keterlambatan; tanggal tidak diisi dengan perkiraan.
- Satu pesanan tidak memiliki baris pembayaran. Hal ini tidak memengaruhi penjualan karena perhitungannya memakai harga item.
- Sebanyak 768 pesanan tanpa skor ulasan valid tidak masuk perbandingan rating.
- Baris geolokasi yang identik tetap dipertahankan. Tabel ini tidak digunakan dalam KPI utama.
- Total harga item pesanan terkirim cocok dengan view tingkat pesanan; selisihnya R$ 0,00.

## Batas interpretasi

Dataset bersifat historis, anonim, dan observasional. Perbedaan tingkat keterlambatan atau rating tidak membuktikan hubungan sebab-akibat dan dapat dipengaruhi waktu, kategori, serta wilayah. Karena data tidak mencakup seluruh biaya dan retur, penjualan produk tidak dapat dianggap sebagai laba atau pendapatan bersih.
