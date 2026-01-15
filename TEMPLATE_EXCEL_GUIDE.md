# Template Excel untuk K-Means Clustering

## Format File Excel

### Kolom yang Diperlukan (Urutan harus sesuai):

| No | Kolom                  | Tipe Data | Contoh  | Keterangan |
|----|------------------------|-----------|---------|------------|
| 1  | Nama Barang           | Text      | Kertas A4 | Nama item barang |
| 2  | Stok Awal             | Number    | 100     | Stok awal periode |
| 3  | Stok Akhir            | Number    | 50      | Stok akhir periode |
| 4  | Jumlah Masuk          | Number    | 200     | Total barang masuk |
| 5  | Jumlah Keluar         | Number    | 150     | Total barang keluar |
| 6  | Rata-rata Pemakaian   | Number    | 15.5    | Rata-rata pemakaian per periode |
| 7  | Frekuensi Restock     | Number    | 5       | Jumlah kali restock |
| 8  | Day To Stock Out      | Number    | 3.2     | Estimasi hari hingga habis |
| 9  | Fluktuasi Pemakaian   | Number    | 2.5     | Tingkat fluktuasi pemakaian |

### Contoh Data Excel:

```
| Nama Barang | Stok Awal | Stok Akhir | Jumlah Masuk | Jumlah Keluar | Rata-rata Pemakaian | Frekuensi Restock | Day To Stock Out | Fluktuasi Pemakaian |
|-------------|-----------|------------|--------------|---------------|---------------------|-------------------|------------------|---------------------|
| Kertas A4   | 100       | 50         | 200          | 150           | 15.5                | 5                 | 3.2              | 2.5                 |
| Tinta HP    | 30        | 10         | 50           | 40            | 5.2                 | 8                 | 1.9              | 3.1                 |
| Spidol      | 60        | 45         | 80           | 35            | 4.5                 | 3                 | 10               | 1.2                 |
| Penghapus   | 200       | 180        | 300          | 120           | 12                  | 2                 | 15               | 0.8                 |
```

## Petunjuk Penggunaan:

1. **Buat File Excel Baru**
   - Bisa menggunakan Microsoft Excel, Google Sheets, atau LibreOffice Calc
   - Format file: `.xlsx` atau `.xls`

2. **Isi Header (Baris 1)**
   - Baris pertama adalah header
   - Header akan diabaikan oleh sistem
   - Pastikan urutan kolom sesuai dengan template

3. **Isi Data (Mulai Baris 2)**
   - Data dimulai dari baris kedua
   - Minimal **3 baris data** diperlukan untuk analisis K-Means
   - Pastikan semua kolom angka berisi nilai numerik (bukan text)

4. **Tips Agar Tidak Error:**
   - ✅ Jangan ada baris kosong di tengah data
   - ✅ Pastikan format sel angka adalah "Number" bukan "Text"
   - ✅ Gunakan titik (.) untuk desimal, bukan koma (,)
   - ✅ Jangan ada karakter khusus di kolom angka
   - ✅ Nama barang tidak boleh kosong

5. **Save dan Upload**
   - Save file Excel
   - Upload melalui aplikasi
   - Sistem akan memproses dan menampilkan preview

## Troubleshooting:

### Masalah: Kolom angka terbaca 0 semua
**Solusi:**
- Pastikan format cell adalah "Number" bukan "Text"
- Di Excel: Pilih kolom → Klik kanan → Format Cells → Number
- Ketik ulang angka jika perlu

### Masalah: Error "Tidak ada data yang valid"
**Solusi:**
- Pastikan minimal ada 3 baris data (selain header)
- Pastikan kolom "Nama Barang" tidak kosong
- Cek tidak ada baris yang semua kolomnya kosong

### Masalah: File tidak bisa diupload
**Solusi:**
- Pastikan format file `.xlsx` atau `.xls`
- Ukuran file tidak terlalu besar (max 10MB)
- Coba save ulang file Excel nya

## Debug Mode:

Jika masih ada masalah, sistem akan menampilkan log di console untuk debugging.
Cek console/terminal untuk melihat:
- Tipe data yang dibaca dari setiap cell
- Nilai yang berhasil di-parse
- Error spesifik yang terjadi
