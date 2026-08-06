# 🥗 NutriScan AI — Bagian Machine Learning

> 📌 Ini adalah dokumentasi khusus bagian **Machine Learning**. Untuk gambaran umum seluruh proyek (termasuk aplikasi Flutter), lihat [README utama](../README.md).

**Aplikasi Mobile Berbasis Machine Learning untuk Menganalisis Kandungan Gizi Makanan dari Foto**

Folder ini berisi program **backend Machine Learning (Python)** untuk NutriScan AI — bagian
"otak" dari aplikasi mobile yang mengenali jenis makanan dari foto (Image Recognition)
lalu menampilkan estimasi kandungan gizinya, guna membantu pengguna menjaga pola makan sehat.

---

## 📁 Struktur Project

```
ml-model/
├── dataset/                  # Folder dataset foto makanan (per kelas per folder)
│   ├── nasi_goreng/
│   ├── ayam_goreng/
│   ├── nasi_padang/
│   ├── gado_gado/
│   └── tempe_goreng/
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
└── README.md                 # File ini
```

---

## 🧠 Pendekatan Machine Learning

| Aspek | Detail |
|---|---|
| **Task** | Image Classification (Image Recognition) |
| **Arsitektur** | Transfer Learning dari **MobileNetV2** (pre-trained ImageNet) |
| **Alasan pilih MobileNetV2** | Ringan, cepat, dan didesain khusus untuk perangkat mobile |
| **Output akhir** | Model `.tflite` — siap dijalankan **langsung di HP** (on-device, offline, tanpa perlu kirim foto ke server) |
| **Strategi training** | 2 tahap: (1) latih classifier head, (2) fine-tuning sebagian layer akhir MobileNetV2 |
| **Augmentasi data** | Flip, rotasi, zoom, kontras — agar model tahan terhadap variasi foto asli dari pengguna |

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
- Tambah kelas makanan baru selain 5 yang ada sekarang (nasi_goreng, ayam_goreng,
  nasi_padang, gado_gado, tempe_goreng) untuk memperluas cakupan aplikasi.
- Perbanyak dan pastikan dataset representatif (variasi makanan Nusantara,
  angle foto, pencahayaan) agar model general dan tidak bias.

---

## ⚠️ Catatan Penting

- Kode ini adalah **prototipe/backbone ML**, bukan aplikasi mobile jadi. Untuk
  aplikasi mobile utuh, model `.tflite` ini perlu diintegrasikan ke project
  Android (Kotlin/Java) atau Flutter/React Native.
- Model butuh **dataset foto makanan asli** (bukan dataset dummy) untuk hasil
  yang akurat — kualitas model sangat bergantung pada kualitas & jumlah data training.
