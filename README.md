# NutriScan AI

**Aplikasi Mobile Berbasis Machine Learning untuk Menganalisis Kandungan Gizi Makanan dari Foto.**

- **Manfaat:** Membantu menjaga pola makan sehat dengan memindai foto makanan dan mendapatkan informasi gizi + penilaian kesehatan secara instan.
- **Machine Learning:** Image Recognition (klasifikasi gambar makanan) menggunakan TensorFlow Lite, dijalankan *on-device* di aplikasi Flutter.

## Struktur Proyek
```
NutriScanAI/
├── backend/          → REST API PHP + MySQL (lihat backend/README.md)
└── flutter_app/       → Aplikasi mobile Flutter
```

## Kesesuaian dengan Alur Pembuatan (PDF)

| # | Tahap                     | Lokasi di Proyek Ini                                             |
|---|----------------------------|--------------------------------------------------------------------|
| 1 | Analisis Kebutuhan          | Deskripsi tujuan, fitur & pengguna (dokumen ini)                   |
| 2 | Perancangan UI/UX            | `flutter_app/lib/screens/*` (mengikuti mockup: splash, login, dashboard, scan, hasil, riwayat, tips, profil) |
| 3 | Perancangan Database          | `backend/sql/nutriscan.sql` (tabel `users`, `foods`, `history`)     |
| 4 | Pembuatan Backend              | `backend/api/*` (REST API PHP: login, register, foods, history, profile) |
| 5 | Pembuatan Frontend Flutter      | `flutter_app/lib/screens/*`, terhubung ke API via `lib/services/api_service.dart` |
| 6 | Integrasi Kamera                 | `flutter_app/lib/screens/scan_screen.dart` (plugin `image_picker`)  |
| 7 | Integrasi AI                      | `flutter_app/lib/services/ml_service.dart` (TensorFlow Lite, on-device inference) |
| 8 | Pengambilan Data Gizi               | `backend/api/foods/classify.php` (label AI → data gizi di MySQL)   |
| 9 | Penyimpanan Riwayat                  | `backend/api/history/index.php` (POST) menyimpan hasil scan ke MySQL |
| 10| Pengujian                             | Lihat bagian "Pengujian" di bawah                                   |
| 11| Deploy                                 | `backend/README.md` bagian "Deploy ke Hostinger"; build APK Flutter |
| 12| Pemeliharaan                            | Perbaikan bug & penambahan fitur berkelanjutan                     |

## Cara Menjalankan

### 1. Backend
Lihat `backend/README.md` untuk setup database & REST API (lokal via XAMPP/Laragon, atau deploy ke Hostinger).

### 2. Flutter App
```bash
cd flutter_app
flutter pub get
flutter run
```
Sebelum menjalankan:
1. Sesuaikan `baseUrl` di `lib/services/api_service.dart` dengan alamat backend Anda.
2. Letakkan model hasil training Anda di `assets/models/food_model.tflite` (lihat bagian "Model AI" di bawah). Label kelas ada di `assets/models/labels.txt`.

## Model AI (Image Recognition)
Proyek ini menyediakan kerangka integrasi TensorFlow Lite (`lib/services/ml_service.dart`) yang:
1. Memuat model `food_model.tflite` beserta `labels.txt` saat splash screen.
2. Melakukan preprocessing gambar (resize 224x224, normalisasi 0–1).
3. Menjalankan inferensi on-device dan mengambil label dengan probabilitas tertinggi.
4. Mengirim label tersebut ke backend (`/foods/classify.php`) untuk mengambil data gizi lengkap.

**Anda perlu melatih model sendiri** (mis. dengan transfer learning MobileNetV2 di TensorFlow/Keras, lalu dikonversi ke `.tflite`) menggunakan dataset foto makanan sesuai label pada `labels.txt`, atau menambah/menyesuaikan label & data gizi di `backend/sql/nutriscan.sql` sesuai dataset Anda.

## Pengujian (Tahap 10)
Rekomendasi pengujian sebelum deploy:
- **Unit/API testing:** gunakan Postman/Insomnia untuk menguji setiap endpoint di `backend/api/`.
- **Pengujian AI:** uji akurasi model dengan data uji terpisah dari data training.
- **Pengujian UI:** `flutter test` untuk widget test dasar, serta pengujian manual di berbagai ukuran layar.
- **Black-box testing:** uji alur end-to-end sebagai pengguna (register → login → scan → simpan riwayat → lihat profil).

## Build APK (Tahap 11)
```bash
cd flutter_app
flutter build apk --release
```
File APK akan tersedia di `build/app/outputs/flutter-apk/app-release.apk`.
