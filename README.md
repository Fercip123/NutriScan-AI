# 🥗 NutriScan AI

**Aplikasi Mobile Berbasis Machine Learning untuk Menganalisis Kandungan Gizi Makanan dari Foto**

HEAD
Repo ini berisi program **backend Machine Learning (Python)** untuk NutriScan AI — bagian
"otak" dari aplikasi mobile yang mengenali jenis makanan dari foto (Image Recognition)
lalu menampilkan estimasi kandungan gizinya, guna membantu pengguna menjaga pola makan sehat.

---

## 📁 Struktur Project

```
nutriscan_ai/
├── dataset/                  # Folder dataset foto makanan (per kelas per folder)
│   ├── nasi_goreng/
│   ├── ayam_goreng/
│   ├── sayur_bayam/
│   ├── tempe_goreng/
│   └── telur_dadar/
├── model/                    # Output model hasil training
│   ├── nutriscan_model.keras     # Model Keras (untuk server/testing)
│   ├── nutriscan_model.tflite    # Model TFLite (untuk deploy ke Android/iOS)
│   ├── labels.txt                # Daftar label kelas
│   └── metadata.json             # Info training (akurasi, ukuran gambar, dll)
├── src/
│   ├── nutrition_db.py       # Database kandungan gizi tiap makanan
│   ├── train_model.py        # Script training model (Transfer Learning MobileNetV2)
│   ├── predict.py            # Script prediksi pakai model Keras
│   └── predict_tflite.py     # Script prediksi pakai model TFLite (simulasi mobile)
├── output/                   # Hasil prediksi (JSON) tersimpan di sini
├── requirements.txt
└── README.md
```

---

## 🧠 Pendekatan Machine Learning

| Aspek                        | Detail                                                                                                      |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **Task**                     | Image Classification (Image Recognition)                                                                    |
| **Arsitektur**               | Transfer Learning dari **MobileNetV2** (pre-trained ImageNet)                                               |
| **Alasan pilih MobileNetV2** | Ringan, cepat, dan didesain khusus untuk perangkat mobile                                                   |
| **Output akhir**             | Model `.tflite` — siap dijalankan **langsung di HP** (on-device, offline, tanpa perlu kirim foto ke server) |
| **Strategi training**        | 2 tahap: (1) latih classifier head, (2) fine-tuning sebagian layer akhir MobileNetV2                        |
| **Augmentasi data**          | Flip, rotasi, zoom, kontras — agar model tahan terhadap variasi foto asli dari pengguna                     |

---

## 🚀 Cara Menjalankan

### 1. Install dependencies

```bash
pip install -r requirements.txt
```

### 2. Siapkan dataset

Masukkan foto makanan ke folder sesuai kelasnya di `dataset/`, contoh:

```
dataset/nasi_goreng/foto1.jpg
dataset/nasi_goreng/foto2.jpg
dataset/ayam_goreng/foto1.jpg
...
```

> 💡 Disarankan **minimal 100–300 foto per kelas** dengan variasi sudut & pencahayaan
> agar model akurat. Untuk menambah kelas makanan baru, cukup buat folder baru di
> `dataset/` dan tambahkan datanya di `nutrition_db.py`.

### 3. Training model

```bash
cd src
python train_model.py
```

Output: `model/nutriscan_model.keras`, `model/nutriscan_model.tflite`, `model/labels.txt`

### 4. Uji prediksi dari foto

```bash
python predict.py path/ke/foto_makanan.jpg
```

atau versi TFLite (mensimulasikan cara kerja di aplikasi mobile):

```bash
python predict_tflite.py path/ke/foto_makanan.jpg
```

Contoh output:

```
==================================================
HASIL ANALISIS NUTRISCAN AI
==================================================
Makanan terdeteksi : Ayam Goreng
Tingkat keyakinan  : 94.32%
Porsi              : 1 potong (±150g)
--------------------------------------------------
Kalori             : 320 kkal
Karbohidrat        : 8 g
Protein            : 28 g
Lemak              : 20 g
Serat              : 0 g
Gula               : 0 g
Natrium            : 480 mg
--------------------------------------------------
Kategori           : Protein tinggi
Catatan kesehatan  : Sumber protein baik, namun tinggi lemak jenuh akibat proses goreng.
==================================================
```

Hasil juga otomatis disimpan sebagai JSON di `output/hasil_prediksi.json` —
format inilah yang nantinya dikonsumsi oleh aplikasi mobile (Android/iOS/Flutter).

---

## 📱 Integrasi ke Aplikasi Mobile

File `model/nutriscan_model.tflite` adalah output final yang dipakai di sisi mobile:

- **Android**: gunakan library `TensorFlow Lite Support Library` / `ML Kit Custom Models`
- **iOS**: gunakan `TensorFlow Lite Swift/Objective-C API`
- **Flutter**: gunakan package `tflite_flutter`

Alur di aplikasi:

1. User membuka kamera & memotret makanan
2. Foto diproses langsung di HP oleh model `.tflite` (tanpa perlu internet)
3. Hasil klasifikasi dicocokkan ke database gizi (bisa disinkronkan dari `nutrition_db.py`
   ke format JSON/Firebase agar mudah diakses aplikasi)
4. Aplikasi menampilkan kalori, makro nutrien, dan catatan kesehatan ke user

---

## 🔧 Pengembangan Lanjutan (Rekomendasi)

- Ganti `nutrition_db.py` dengan data resmi dari **TKPI (Tabel Komposisi Pangan
  Indonesia - Kemenkes)** atau **USDA FoodData Central** agar lebih akurat & lengkap.
- Tambahkan **estimasi porsi otomatis** (misal pakai depth estimation atau referensi
  ukuran piring) agar kalori dihitung sesuai porsi riil, bukan porsi standar.
- Tambahkan fitur **deteksi multi-makanan dalam satu foto** (object detection,
  misal YOLO) untuk piring dengan banyak jenis makanan sekaligus.
- Tambahkan **riwayat asupan harian** dan rekomendasi pola makan berdasarkan
  tujuan user (diet, bulking, dsb.).
- Perbanyak dan pastikan dataset representatif (variasi makanan Nusantara,
  angle foto, pencahayaan) agar model general dan tidak bias.

---

## ⚠️ Catatan Penting

- Kode ini adalah **prototipe/backbone ML**, bukan aplikasi mobile jadi. Untuk
  aplikasi mobile utuh, model `.tflite` ini perlu diintegrasikan ke project
  Android (Kotlin/Java) atau Flutter/React Native.
- Model butuh **dataset foto makanan asli** (bukan dataset dummy) untuk hasil
  yang akurat — kualitas model sangat bergantung pada kualitas & jumlah data training.
  =======
  NutriScan AI membantu pengguna menjaga pola makan sehat dengan memanfaatkan
  **Image Recognition (Deep Learning)** untuk mengenali jenis makanan dari foto,
  lalu menampilkan estimasi kandungan gizinya secara instan — tanpa perlu input
  manual atau koneksi internet (inference berjalan langsung di perangkat).

---

## 👥 Kontributor

| Nama                       | Peran                                                                |
| -------------------------- | -------------------------------------------------------------------- |
| [Ferry Chandra Yudhistira] | Machine Learning Engineer — dataset, training model, evaluasi        |
| [Radot]                    | Mobile Developer — desain UI/UX, integrasi model ke aplikasi Flutter |

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

| Layer            | Teknologi                                                 |
| ---------------- | --------------------------------------------------------- |
| Machine Learning | Python, TensorFlow/Keras, MobileNetV2 (Transfer Learning) |
| Model Deployment | TensorFlow Lite (TFLite)                                  |
| Aplikasi Mobile  | Flutter, tflite_flutter                                   |

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
7eb260404507bf4c0c4eafc78893ae5a775d253d
