"""
train_model.py
----------------
Training model Image Recognition untuk NutriScan AI.

Pendekatan  : Transfer Learning dengan MobileNetV2
Alasan      : MobileNetV2 ringan & cepat, cocok untuk diconversi ke
              TensorFlow Lite (TFLite) agar bisa berjalan di aplikasi mobile
              (Android/iOS) secara on-device (offline, hemat kuota, cepat).

Cara pakai:
1. Siapkan dataset foto makanan di folder:
   dataset/
     nasi_goreng/   -> berisi foto-foto nasi goreng
     ayam_goreng/   -> berisi foto-foto ayam goreng
     sayur_bayam/   -> dst.
     ...
   Minimal disarankan 100-300 foto per kelas untuk hasil yang baik.

2. Jalankan:
   python train_model.py

3. Output:
   - model/nutriscan_model.h5      -> model Keras
   - model/nutriscan_model.tflite  -> model siap dipakai di aplikasi mobile
   - model/labels.txt              -> daftar label kelas
"""

import os
import json
import tensorflow as tf
import keras

from keras import layers, models
from keras.applications import MobileNetV2
from keras.applications.mobilenet_v2 import preprocess_input

# ========== KONFIGURASI ==========
DATASET_DIR = os.path.join(os.path.dirname(__file__), "..", "dataset")
MODEL_DIR = os.path.join(os.path.dirname(__file__), "..", "model")
IMG_SIZE = (224, 224)      # ukuran input standar MobileNetV2
BATCH_SIZE = 32
EPOCHS_HEAD = 8            # tahap 1: hanya melatih classifier head
EPOCHS_FINE_TUNE = 5       # tahap 2: fine-tuning sebagian layer MobileNet
LEARNING_RATE = 1e-3
FINE_TUNE_LR = 1e-5

os.makedirs(MODEL_DIR, exist_ok=True)


def build_datasets():
    """Memuat dataset dari folder dan membaginya menjadi train/validation."""
    train_ds = tf.keras.utils.image_dataset_from_directory(
        DATASET_DIR,
        validation_split=0.2,
        subset="training",
        seed=42,
        image_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
    )
    val_ds = tf.keras.utils.image_dataset_from_directory(
        DATASET_DIR,
        validation_split=0.2,
        subset="validation",
        seed=42,
        image_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
    )

    class_names = train_ds.class_names
    print(f"Kelas terdeteksi ({len(class_names)}): {class_names}")

    # Augmentasi data agar model lebih tahan terhadap variasi foto asli
    # (sudut kamera, pencahayaan, dsb.) — penting karena foto makanan dari
    # pengguna aplikasi mobile sangat bervariasi kondisinya.
    data_augmentation = tf.keras.Sequential([
        layers.RandomFlip("horizontal"),
        layers.RandomRotation(0.1),
        layers.RandomZoom(0.1),
        layers.RandomContrast(0.1),
    ])

    AUTOTUNE = tf.data.AUTOTUNE
    train_ds = train_ds.map(
        lambda x, y: (data_augmentation(x, training=True), y),
        num_parallel_calls=AUTOTUNE
    ).prefetch(AUTOTUNE)
    val_ds = val_ds.prefetch(AUTOTUNE)

    return train_ds, val_ds, class_names


def build_model(num_classes: int):
    """Bangun model dengan transfer learning dari MobileNetV2 (ImageNet)."""
    try:
        base_model = MobileNetV2(
            input_shape=IMG_SIZE + (3,),
            include_top=False,
            weights="imagenet",
        )
        print("Bobot pretrained ImageNet berhasil dimuat (transfer learning aktif).")
    except Exception as e:
        # Fallback: jika tidak ada akses internet ke server bobot pretrained
        # (mis. di lingkungan sandbox/offline), gunakan bobot random.
        # Di lingkungan produksi dengan akses internet normal, blok ini
        # tidak akan pernah terpakai karena weights="imagenet" akan berhasil.
        print(f"[PERINGATAN] Gagal memuat bobot ImageNet ({e}).")
        print("Melanjutkan dengan bobot acak (weights=None) sebagai fallback.")
        base_model = MobileNetV2(
            input_shape=IMG_SIZE + (3,),
            include_top=False,
            weights=None,
        )
    base_model.trainable = False  # tahap 1: bekukan bobot backbone

    inputs = tf.keras.Input(shape=IMG_SIZE + (3,))
    x = preprocess_input(inputs)
    x = base_model(x, training=False)
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.Dropout(0.3)(x)
    x = layers.Dense(128, activation="relu")(x)
    x = layers.Dropout(0.2)(x)
    outputs = layers.Dense(num_classes, activation="softmax")(x)

    model = models.Model(inputs, outputs)
    return model, base_model


def main():
    train_ds, val_ds, class_names = build_datasets()
    num_classes = len(class_names)

    model, base_model = build_model(num_classes)

    # ===== TAHAP 1: Melatih classifier head =====
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=LEARNING_RATE),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )
    print("\n=== TAHAP 1: Training classifier head ===")
    model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS_HEAD)

    # ===== TAHAP 2: Fine-tuning sebagian layer MobileNetV2 =====
    base_model.trainable = True
    # Bekukan layer awal, hanya fine-tune layer akhir agar tidak overfitting
    fine_tune_at = len(base_model.layers) - 30
    for layer in base_model.layers[:fine_tune_at]:
        layer.trainable = False

    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=FINE_TUNE_LR),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )
    print("\n=== TAHAP 2: Fine-tuning ===")
    model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS_FINE_TUNE)

    # ===== Evaluasi akhir =====
    loss, acc = model.evaluate(val_ds)
    print(f"\nAkurasi validasi akhir: {acc*100:.2f}%")

    # ===== Simpan model Keras (format native .keras, lebih andal daripada .h5 legacy) =====
    keras_path = os.path.join(MODEL_DIR, "nutriscan_model.keras")
    model.save(keras_path)
    print(f"Model Keras disimpan di: {keras_path}")

    # ===== Simpan label kelas =====
    labels_path = os.path.join(MODEL_DIR, "labels.txt")
    with open(labels_path, "w") as f:
        f.write("\n".join(class_names))
    print(f"Label kelas disimpan di: {labels_path}")

    # ===== Konversi ke TensorFlow Lite untuk deployment mobile =====
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]  # kuantisasi -> ukuran lebih kecil
    tflite_model = converter.convert()

    tflite_path = os.path.join(MODEL_DIR, "nutriscan_model.tflite")
    with open(tflite_path, "wb") as f:
        f.write(tflite_model)
    print(f"Model TFLite (siap untuk Android/iOS) disimpan di: {tflite_path}")

    # ===== Simpan metadata training =====
    metadata = {
        "class_names": class_names,
        "img_size": IMG_SIZE,
        "final_val_accuracy": float(acc),
    }
    with open(os.path.join(MODEL_DIR, "metadata.json"), "w") as f:
        json.dump(metadata, f, indent=2)


if __name__ == "__main__":
    main()
