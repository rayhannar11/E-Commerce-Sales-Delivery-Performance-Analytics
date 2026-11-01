# Menyiapkan database

Jalankan `create_schemas.sql` dan `create_tables.sql` dari folder utama proyek, lalu muat sembilan CSV dengan `load_csvs.psql`. Perintah `\copy` membaca file dari komputer Anda, sehingga jalankan `psql` dari folder utama proyek agar jalur `data/` ditemukan.

Tabel `raw` mempertahankan baris sumber tanpa batasan primary key atau foreign key yang dapat menolak data. Periksa key melalui query kualitas sebelum mengandalkannya dalam analisis. Kolom prefix kode pos disimpan sebagai teks agar angka nol di depan tidak hilang.
