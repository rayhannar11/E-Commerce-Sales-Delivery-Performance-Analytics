# Laporan kualitas data

Pemeriksaan dilakukan pada sembilan CSV Olist. Baris sumber tetap dipertahankan; hasil pemeriksaan digunakan untuk menentukan data yang masuk ke perhitungan KPI.

## Ringkasan sumber

| Tabel | Baris | Kolom | Baris duplikat persis | Duplikat key kandidat | Sel kosong | Rentang tanggal |
|---|---:|---:|---:|---:|---:|---|
| `customers` | 99.441 | 5 | 0 | 0 | 0 | - |
| `orders` | 99.441 | 8 | 0 | 0 | 4.908 | 4 Sep 2016 - 17 Okt 2018 |
| `items` | 112.650 | 7 | 0 | 0 | 0 | - |
| `payments` | 103.886 | 5 | 0 | 0 | 0 | - |
| `reviews` | 99.224 | 7 | 0 | 0 | 145.903 | 2 Okt 2016 - 31 Agu 2018 |
| `products` | 32.951 | 9 | 0 | 0 | 2.448 | - |
| `sellers` | 3.095 | 4 | 0 | 0 | 0 | - |
| `geolocation` | 1.000.163 | 5 | 261.831 | Tidak berlaku | 0 | - |
| `translation` | 71 | 2 | 0 | 0 | 0 | - |

## Pemeriksaan dan dampaknya

| Pemeriksaan | Jumlah | Penanganan |
|---|---:|---|
| Pesanan tanpa data pelanggan yang cocok | 0 | Tidak ditemukan masalah pada relasi ini. |
| Item tanpa pesanan yang cocok | 0 | Tidak ditemukan masalah pada relasi ini. |
| Harga item atau ongkos kirim bernilai negatif | 0 | Tidak ditemukan nilai negatif. |
| Pesanan tiba sebelum waktu pembelian | 0 | Tidak ditemukan urutan tanggal yang tidak wajar. |
| Pesanan terkirim tanpa tanggal tiba | 8 | Dikeluarkan dari perhitungan durasi dan tingkat keterlambatan. |
| Pesanan terkirim tanpa tanggal estimasi | 0 | Tidak mengurangi cakupan denominator keterlambatan. |
| Nilai `review_id` yang digunakan ulang di pesanan berbeda | 789 | `review_id` tidak digunakan sebagai key tunggal. |
| Pesanan dengan lebih dari satu baris ulasan | 547 | Skor valid dirata-ratakan per pesanan. |
| Pesanan tanpa skor ulasan valid | 768 | Tidak masuk perbandingan rating. |
| Pesanan tanpa baris pembayaran | 1 | Tidak memengaruhi penjualan yang dihitung dari harga item. |
| Item tanpa produk atau penjual yang cocok | 0 | Tidak ditemukan masalah pada relasi ini. |
| Pesanan tanpa identitas pelanggan yang valid | 0 | Tidak ditemukan masalah pada populasi analisis pelanggan. |

## Catatan penting

- Kunci gabungan ulasan `(order_id, review_id)` unik. Ada 789 nilai `review_id` yang muncul di beberapa pesanan (814 baris berlebih jika diuji sebagai key tunggal), jadi ID ulasan saja tidak cukup untuk membedakan semua baris.
- Delapan pesanan terkirim tanpa tanggal aktual tidak masuk metrik durasi dan keterlambatan. Satu pesanan tidak memiliki baris pembayaran; penjualan tetap dihitung dari harga item.
- Tabel geolokasi memiliki 261.831 baris identik dan beberapa titik untuk satu prefix kode pos. Karena itu, tabel ini tidak digabung langsung ke analisis penjualan atau pengiriman.
- Total harga item untuk pesanan terkirim cocok dengan total pada view tingkat pesanan; selisihnya **R$ 0,00**. Duplikat key tidak ditemukan pada tabel pelanggan, pesanan, item, dan urutan pembayaran.

Baris sumber tidak dihapus. Definisi populasi dan denominator dijelaskan di [metodologi](methodology.md).
