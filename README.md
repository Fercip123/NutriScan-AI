# 🥗 NutriScan AI

**Aplikasi Mobile Berbasis Machine Learning untuk Menganalisis Kandungan Gizi Makanan dari Foto**

NutriScan AI membantu pengguna menjaga pola makan sehat dengan memanfaatkan
**Image Recognition (Deep Learning)** untuk mengenali jenis makanan dari foto,
lalu menampilkan estimasi kandungan gizinya secara instan — tanpa perlu input
manual atau koneksi internet (inference berjalan langsung di perangkat).

---

## 👥 Kontributor

| Nama | Peran |
|---|---|
| [Ferry Chandra Yudhistira] | Machine Learning Engineer — dataset, training model, evaluasi |
| [Radot] | Mobile Developer — desain UI/UX, integrasi model ke aplikasi Flutter |

---

## 🧠 Cara Kerja Singkat

1. Pengguna memfoto makanan lewat kamera aplikasi
2. Model **MobileNetV2** (hasil transfer learning) mengklasifikasikan jenis makanan langsung di perangkat (on-device, offline)
3. Hasil klasifikasi dicocokkan dengan database kandungan gizi
4. Aplikasi menampilkan kalori, protein, karbohidrat, lemak, dan catatan kesehatan terkait

---

## 📁 Struktur Repository

```
nutriscan-ai/
├── ml-model/              # Bagian Machine Learning
│   ├── dataset/           # Dataset foto makanan per kelas
│   ├── model/              # Output model (.tflite, labels.txt, dll)
│   ├── src/                 # Script training & prediksi (Python)
│   └── README.md            # Dokumentasi khusus bagian ML
│
├── flutter-app/            # Bagian Aplikasi Mobile
│   ├── lib/                  # Kode Dart aplikasi
│   ├── assets/                # Model .tflite, labels.txt, nutrition_db.json
│   └── README.md               # Dokumentasi khusus bagian aplikasi
│
└── README.md                # Dokumentasi utama (file ini)
```

---

## 🚀 Fitur

- ✅ Deteksi jenis makanan dari foto menggunakan Deep Learning (Image Recognition)
- ✅ Estimasi kandungan gizi otomatis (kalori, karbohidrat, protein, lemak, serat, gula, natrium)
- ✅ Inference on-device — cepat, offline, dan menjaga privasi foto pengguna
- ✅ Catatan kesehatan kontekstual untuk tiap makanan
- 🔜 (rencana pengembangan) Riwayat asupan harian & rekomendasi pola makan

---

## 🛠️ Tech Stack

| Layer | Teknologi |
|---|---|
| Machine Learning | Python, TensorFlow/Keras, MobileNetV2 (Transfer Learning) |
| Model Deployment | TensorFlow Lite (TFLite) |
| Aplikasi Mobile | Flutter, tflite_flutter |

---

## ⚙️ Cara Menjalankan Proyek

### Bagian Machine Learning
Lihat panduan lengkap di [`ml-model/README.md`](./ml-model/README.md) — mencakup cara menyiapkan dataset, training model, dan menghasilkan file `.tflite`.

### Bagian Aplikasi Flutter
Lihat panduan lengkap di [`flutter-app/README.md`](./flutter-app/README.md) — mencakup cara menjalankan aplikasi dan mengganti model bila ada versi baru.

---

## 📌 Status Proyek

Proyek ini merupakan bagian dari [konteks proyek Anda, misal: tugas kuliah/capstone project/dsb — sesuaikan].
Model saat ini mengenali **5 jenis makanan**: Nasi Goreng, Ayam Goreng, Nasi Padang, Gado-Gado, dan Tempe Goreng, dengan akurasi validasi ±85%.

---

## 📄 Lisensi

[Sesuaikan, misal: MIT License — atau kosongkan dulu bila belum ditentukan]
