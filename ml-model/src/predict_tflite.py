"""
predict_tflite.py
----------------
Simulasi inference menggunakan model TFLite — ini merepresentasikan
bagaimana proses prediksi akan berjalan LANGSUNG DI DALAM aplikasi
mobile (on-device inference), tanpa perlu koneksi internet/server.

Di aplikasi Android asli, proses yang sama dilakukan menggunakan
library "TensorFlow Lite Android Support Library" dengan model
nutriscan_model.tflite yang sudah dihasilkan oleh train_model.py.

Cara pakai:
    python predict_tflite.py path/ke/foto_makanan.jpg
"""

import os
import sys
import numpy as np
import tensorflow as tf

from nutrition_db import get_nutrition_info
from predict import print_result

MODEL_DIR = os.path.join(os.path.dirname(__file__), "..", "model")
IMG_SIZE = (224, 224)


class NutriScanTFLitePredictor:
    def __init__(self, tflite_path=None, labels_path=None):
        tflite_path = tflite_path or os.path.join(MODEL_DIR, "nutriscan_model.tflite")
        labels_path = labels_path or os.path.join(MODEL_DIR, "labels.txt")

        self.interpreter = tf.lite.Interpreter(model_path=tflite_path)
        self.interpreter.allocate_tensors()

        self.input_details = self.interpreter.get_input_details()
        self.output_details = self.interpreter.get_output_details()

        with open(labels_path, "r") as f:
            self.class_names = [line.strip() for line in f.readlines()]

    def predict(self, image_path: str, top_k: int = 3) -> dict:
        img = tf.keras.utils.load_img(image_path, target_size=IMG_SIZE)
        img_array = tf.keras.utils.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0).astype(np.float32)
        # preprocess MobileNetV2: skala ke [-1, 1]
        img_array = (img_array / 127.5) - 1.0

        self.interpreter.set_tensor(self.input_details[0]["index"], img_array)
        self.interpreter.invoke()
        predictions = self.interpreter.get_tensor(self.output_details[0]["index"])[0]

        top_indices = predictions.argsort()[-top_k:][::-1]
        top_predictions = [
            {"label": self.class_names[i], "confidence": float(predictions[i]) * 100}
            for i in top_indices
        ]

        best_label = top_predictions[0]["label"]
        best_confidence = top_predictions[0]["confidence"]

        return {
            "prediksi_utama": best_label,
            "confidence_persen": round(best_confidence, 2),
            "alternatif_prediksi": top_predictions,
            "info_gizi": get_nutrition_info(best_label),
            "peringatan_akurasi_rendah": best_confidence < 60,
        }


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Cara pakai: python predict_tflite.py <path_foto_makanan>")
        sys.exit(1)

    predictor = NutriScanTFLitePredictor()
    result = predictor.predict(sys.argv[1])
    print_result(result)
