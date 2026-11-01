# Model analitik

Setelah data dimuat dan diperiksa, jalankan `analytical_views.sql`. Item, pembayaran, dan ulasan diringkas secara terpisah sebelum digabung ke pesanan. Setiap view memiliki tingkat rincian (*grain*) berikut:

- `analytics.order_sales`: satu baris per pesanan.
- `analytics.order_delivery`: satu baris per pesanan; skor beberapa ulasan valid dirata-ratakan per pesanan.
- `analytics.customer_summary`: satu baris per `customer_unique_id` yang memiliki pesanan terkirim.
- `analytics.customer_rfm`: satu baris per identitas pelanggan, dengan snapshot satu hari setelah pembelian terkirim terakhir yang tercatat.
- `analytics.product_category_sales`: ringkasan item dan kategori dari pesanan terkirim.
- `analytics.monthly_sales` dan `analytics.sales_by_state`: ringkasan per bulan dan negara bagian pelanggan.
- `analytics.delivery_by_state`, `analytics.delivery_by_category`, dan `analytics.review_by_delivery_status`: ringkasan keterlambatan dan ulasan pada tingkat rincian yang tertulis di view.

Tabel geolokasi tidak digabung langsung ke transaksi karena satu prefix kode pos dapat berhubungan dengan beberapa titik. Jika ingin memakainya, tentukan dan dokumentasikan cara memilih atau merangkum titiknya terlebih dahulu.
