# NutriScan — Flutter App

Dokumentasi teknis untuk kode aplikasi Flutter NutriScan. Untuk gambaran umum proyek (fitur, model AI, cara instalasi), lihat README utama di root repo.

## Struktur Folder

```
lib/
├── models/            # Model data (mis. FoodResult)
├── screens/           # Seluruh halaman UI aplikasi
│   ├── splash_screen.dart      # Halaman awal, memuat model AI saat start
│   ├── dashboard_screen.dart   # Halaman utama/beranda
│   ├── scan_screen.dart        # Halaman kamera & pemindaian makanan
│   ├── result_screen.dart      # Halaman hasil analisis gizi
│   ├── history_screen.dart     # Riwayat scan tersimpan
│   ├── profile_screen.dart     # Halaman profil pengguna
│   └── tips_screen.dart        # Tips/edukasi gizi
├── services/          # Logika bisnis & akses data
│   ├── ml_service.dart          # Entry point MLService (conditional import)
│   ├── ml_service_native.dart   # Inferensi TFLite untuk Android/iOS/Desktop
│   ├── ml_service_web.dart      # Versi mock untuk Flutter Web (TFLite tidak didukung)
│   ├── food_database_service.dart # Lookup data gizi berdasarkan label hasil AI
│   ├── history_db_service.dart    # Penyimpanan riwayat scan (SQLite)
│   └── profile_service.dart       # Data profil pengguna
└── main.dart          # Entry point aplikasi
```

## Alur Kerja Deteksi Makanan

1. **`scan_screen.dart`** — pengguna memfoto/memilih gambar makanan
2. **`ml_service.dart`** → **`ml_service_native.dart`** — gambar diproses (resize 224x224) dan dijalankan melalui interpreter TensorFlow Lite
3. **`food_database_service.dart`** — label hasil klasifikasi dicocokkan dengan data gizi dari `assets/models/nutrition_db.json`
4. **`result_screen.dart`** — hasil analisis (nama makanan, confidence, info gizi, penilaian kesehatan) ditampilkan ke pengguna
5. Pengguna dapat menyimpan hasil ke riwayat lewat **`history_db_service.dart`**

## Catatan Penting: Preprocessing Gambar

Model `.tflite` sudah menyertakan normalisasi MobileNetV2 (`preprocess_input`) sebagai layer pertama di dalam model itu sendiri. **Jangan** melakukan normalisasi piksel manual (`pixel/127.5 - 1.0`) sebelum mengirim data ke `Interpreter` — cukup kirim nilai piksel mentah (0–255). Melakukan normalisasi dua kali akan merusak akurasi model secara drastis (pernah terjadi, lihat riwayat commit).

## Menjalankan

```bash
flutter pub get
flutter run
```

Requirement: JDK 17 (disarankan set eksplisit lewat `android/gradle.properties` → `org.gradle.java.home`), Android SDK, dan device/emulator dengan minimum API level yang sesuai `compileSdk` di `android/app/build.gradle.kts`.

## To Be Added (TBA)

- [ ] `history_screen.dart` — item riwayat belum bisa dibuka secara penuh/detail
- [ ] `result_screen.dart` — tombol share hasil analisis belum berfungsi
- [ ] Halaman pengaturan belum berfungsi
- [ ] Penambahan jumlah kelas makanan yang dikenali model (saat ini 5 kelas)
