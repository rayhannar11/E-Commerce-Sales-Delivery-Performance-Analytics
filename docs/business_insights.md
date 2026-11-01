# Temuan dan rekomendasi

## Cakupan analisis

Saya menggunakan sembilan tabel dalam dataset Olist Brasil. Data pesanan mencakup September 2016 sampai Oktober 2018. Perhitungan penjualan berfokus pada pesanan berstatus `delivered`.

## Temuan utama

### 1. Penjualan produk mencapai R$ 13.221.498,11

Terdapat **96.478 pesanan terkirim** dengan rata-rata nilai pesanan **R$ 137,04**. Ongkos kirim sebesar **R$ 2.198.275,64** dihitung terpisah. Kategori dengan penjualan tertinggi adalah **Health & Beauty**, sebesar **R$ 1.233.131,72**. Angka penjualan ini berasal dari harga item, bukan laba atau pendapatan bersih.

### 2. Sebanyak 8,11% pesanan yang tanggalnya valid terlambat

Ada **7.826 pesanan terlambat dari 96.470 pesanan** yang memiliki tanggal aktual dan estimasi valid. Waktu pengiriman rata-rata **12,56 hari**. Jika dilihat dari persentase, **AL** tertinggi (**23,9%; 95 dari 397**) dan disusul **MA** (**19,7%; 141 dari 717**). Jika dilihat dari jumlah kasus, **SP** tertinggi dengan **2.387 pesanan terlambat** (**5,9% dari 40.494**).

Persentase dan jumlah kasus memberi gambaran yang berbeda. AL dan MA layak ditinjau karena persentasenya tinggi, sedangkan SP memiliki jumlah kasus terbesar. Sebelum menentukan tindakan, periksa juga komposisi bulan dan kategori.

### 3. Rating pesanan terlambat lebih rendah di data ini

Rata-rata rating per pesanan adalah **2,57/5** untuk pesanan terlambat (**7.661 ulasan**) dan **4,29/5** untuk pesanan tepat waktu (**88.163 ulasan**). Proporsi pesanan dengan rating rata-rata 2 atau lebih rendah masing-masing **54,0%** dan **9,2%**. Perbandingan ini menunjukkan hubungan dalam data, tetapi tidak membuktikan bahwa keterlambatan menyebabkan rating turun.

### 4. Pembelian ulang tercatat sebesar 3,00%

Sebanyak **2.801 dari 93.358 pelanggan** yang memiliki setidaknya satu pesanan terkirim melakukan dua pesanan atau lebih selama periode dataset. Angka ini hanya menggambarkan periode historis dan definisi pelanggan yang digunakan dalam analisis.

### 5. Kategori Audio memiliki tingkat keterlambatan tertinggi

Tingkat keterlambatan kategori Audio adalah **12,9% dari 348 pesanan** yang tanggalnya valid. Angka ini bisa menjadi bahan pemeriksaan, tetapi belum cukup untuk menyimpulkan adanya masalah pada kategori tersebut. Periksa juga wilayah dan bulan pengiriman.

## Rekomendasi

1. Tinjau rute dan proses pengiriman di AL dan MA, sambil tetap memantau jumlah kasus besar di SP.
2. Bandingkan keterlambatan dan rating dalam kelompok bulan, wilayah, dan kategori yang sama sebelum menguji perubahan operasional.
3. Pantau pembelian ulang berdasarkan kelompok waktu pelanggan (*cohort*) dengan definisi pesanan yang konsisten. Jangan gunakan angka historis ini sebagai prediksi.

## Batasan

Delapan pesanan terkirim tanpa tanggal aktual tidak masuk perhitungan durasi dan keterlambatan. Sebanyak 547 pesanan memiliki lebih dari satu baris ulasan; skor validnya dirata-ratakan per pesanan. Harga item tidak mencakup seluruh biaya dan retur, sehingga data ini tidak cukup untuk menghitung laba. Dataset bersifat historis, anonim, dan observasional.
