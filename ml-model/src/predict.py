"""
predict.py
----------------
Modul prediksi (inference) untuk NutriScan AI.

Alur kerja:
1. User memfoto makanan di aplikasi mobile
2. Foto dikirim/diproses ke model image recognition (MobileNetV2 hasil training)
3. Model mengklasifikasikan jenis makanan
4. Sistem mencocokkan hasil klasifikasi dengan database gizi
5. Aplikasi menampilkan hasil analisis kandungan gizi ke user

Script ini bisa dijalankan langsung dari command line untuk menguji model:
    python predict.py path/ke/foto_makanan.jpg
"""

import os
import sys
import json
import numpy as np
import tensorflow as tf
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input

from nutrition_db import get_nutrition_info

MODEL_DIR = os.path.join(os.path.dirname(__file__), "..", "model")
IMG_SIZE = (224, 224)


class NutriScanPredictor:
    """Kelas utama untuk melakukan prediksi jenis makanan dari foto."""

    def __init__(self, model_path=None, labels_path=None):
        model_path = model_path or os.path.join(MODEL_DIR, "nutriscan_model.keras")
        labels_path = labels_path or os.path.join(MODEL_DIR, "labels.txt")

        if not os.path.exists(model_path):
            raise FileNotFoundError(
                f"Model tidak ditemukan di {model_path}.\n"
                f"Jalankan train_model.py terlebih dahulu untuk melatih model."
            )

        self.model = tf.keras.models.load_model(model_path)

        with open(labels_path, "r") as f:
            self.class_names = [line.strip() for line in f.readlines()]

    def preprocess_image(self, image_path: str) -> np.ndarray:
        """Membaca dan menyiapkan gambar agar sesuai format input model."""
        img = tf.keras.utils.load_img(image_path, target_size=IMG_SIZE)
        img_array = tf.keras.utils.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0)  # tambah dimensi batch
        img_array = preprocess_input(img_array)
        return img_array

    def predict(self, image_path: str, top_k: int = 3) -> dict:
        """
        Melakukan prediksi jenis makanan dari sebuah foto.

        Return:
            dict berisi label prediksi utama, tingkat keyakinan (confidence),
            top-k prediksi alternatif, dan info kandungan gizi lengkap.
        """
        img_array = self.preprocess_image(image_path)
        predictions = self.model.predict(img_array, verbose=0)[0]

        # Urutkan hasil prediksi dari yang paling yakin
        top_indices = predictions.argsort()[-top_k:][::-1]
        top_predictions = [
            {
                "label": self.class_names[i],
                "confidence": float(predictions[i]) * 100
            }
            for i in top_indices
        ]

        best_label = top_predictions[0]["label"]
        best_confidence = top_predictions[0]["confidence"]
        nutrition_info = get_nutrition_info(best_label)

        result = {
            "prediksi_utama": best_label,
            "confidence_persen": round(best_confidence, 2),
            "alternatif_prediksi": top_predictions,
            "info_gizi": nutrition_info,
            "peringatan_akurasi_rendah": best_confidence < 60,
        }
        return result


def print_result(result: dict):
    """Menampilkan hasil analisis gizi dengan format yang mudah dibaca."""
    print("\n" + "=" * 50)
    print("HASIL ANALISIS NUTRISCAN AI")
    print("=" * 50)
    info = result["info_gizi"]
    print(f"Makanan terdeteksi : {info['nama']}")
    print(f"Tingkat keyakinan  : {result['confidence_persen']}%")

    if result["peringatan_akurasi_rendah"]:
        print("⚠ Keyakinan model rendah, hasil mungkin kurang akurat.")

    print(f"Porsi              : {info['porsi']}")
    print("-" * 50)
    print(f"Kalori             : {info['kalori_kcal']} kkal")
    print(f"Karbohidrat        : {info['karbohidrat_g']} g")
    print(f"Protein            : {info['protein_g']} g")
    print(f"Lemak              : {info['lemak_g']} g")
    print(f"Serat              : {info['serat_g']} g")
    print(f"Gula               : {info['gula_g']} g")
    print(f"Natrium            : {info['natrium_mg']} mg")
    print("-" * 50)
    print(f"Kategori           : {info['kategori']}")
    print(f"Catatan kesehatan  : {info['catatan_sehat']}")
    print("=" * 50)

    print("\nAlternatif prediksi lain:")
    for p in result["alternatif_prediksi"]:
        print(f"  - {p['label']}: {p['confidence']:.2f}%")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Cara pakai: python predict.py <path_foto_makanan>")
        sys.exit(1)

    image_path = sys.argv[1]
    predictor = NutriScanPredictor()
    result = predictor.predict(image_path)
    print_result(result)

    # Simpan hasil sebagai JSON (contoh format yang akan dikirim ke app mobile)
    output_path = os.path.join(
        os.path.dirname(__file__), "..", "output", "hasil_prediksi.json"
    )
    with open(output_path, "w") as f:
        json.dump(result, f, indent=2, ensure_ascii=False)
    print(f"\nHasil juga disimpan sebagai JSON di: {output_path}")
