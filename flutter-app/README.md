# NutriScan

Aplikasi mobile berbasis *machine learning* untuk menganalisis kandungan gizi makanan hanya dari foto. Foto makanan diklasifikasikan langsung di perangkat (*on-device inference*, tanpa server/koneksi internet) menggunakan model TensorFlow Lite, lalu hasilnya dicocokkan dengan database kandungan gizi lokal.

## Fitur

- **Deteksi makanan dari foto** — ambil foto langsung dari kamera atau pilih dari galeri
- **Analisis gizi otomatis** — kalori, karbohidrat, protein, lemak, serat, gula, dan natrium per porsi
- **Penilaian kesehatan** — catatan singkat mengenai kandungan gizi makanan yang terdeteksi
- **Riwayat scan** — hasil analisis dapat disimpan dan dilihat kembali
- **100% on-device** — inferensi AI dan penyimpanan data berjalan lokal di HP (SQLite), tanpa server eksternal

## Teknologi

- **Flutter** — kerangka kerja aplikasi mobile (Android)
- **TensorFlow Lite** (`tflite_flutter`) — inferensi model AI on-device
- **MobileNetV2** (*transfer learning*) — arsitektur dasar model klasifikasi gambar
- **sqflite** — penyimpanan riwayat lokal (SQLite)
- **image_picker** — integrasi kamera & galeri

## Model AI

Model saat ini dilatih untuk mengenali **5 kelas makanan**:

- Ayam Goreng
- Gado-Gado
- Nasi Goreng
- Nasi Padang
- Tempe Goreng

Setiap kelas dilatih menggunakan 400+ foto, dengan pendekatan *transfer learning* dari MobileNetV2 (bobot ImageNet), lalu di-*fine-tune* dan dikonversi ke format TensorFlow Lite (`.tflite`) untuk dijalankan langsung di perangkat mobile.

## Struktur Proyek

Repo ini berisi dua struktur folder Flutter:

- **`lib/`** (di root) — versi aplikasi yang **digunakan/aktif**. Tanpa sistem login, memakai `sqflite` untuk penyimpanan lokal, dan model AI berjalan on-device.
- **`flutter_app/lib/`** — versi lama/eksperimen (ada sistem login, memakai HTTP ke server API). **Tidak digunakan**, disimpan hanya sebagai arsip.

Jalankan proyek dari folder root (tempat `pubspec.yaml` berada), bukan dari dalam `flutter_app/`.

## Menjalankan Proyek

```bash
flutter pub get
flutter run
```

Model, label, dan database gizi sudah termasuk sebagai *assets* bawaan (`assets/models/`), jadi tidak perlu setup tambahan untuk menjalankan aplikasi.

## Rilis

Lihat halaman [Releases](releases) untuk mengunduh versi APK yang sudah dibangun.

## To Be Added (TBA)

Daftar hal yang masih perlu diperbaiki/dikerjakan:

- [ ] Riwayat scan belum bisa dibuka secara penuh/detail
- [ ] Tombol share hasil analisis belum berfungsi
- [ ] Halaman pengaturan belum berfungsi
- [ ] Penambahan jumlah kelas makanan yang dikenali (saat ini masih 5 kelas)

## Lisensi

Proyek ini menggunakan lisensi MIT — lihat file [LICENSE](LICENSE) untuk detail.
