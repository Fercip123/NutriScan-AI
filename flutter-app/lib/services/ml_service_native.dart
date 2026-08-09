import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Versi NATIVE (Android/iOS/Desktop) dari MLService.
/// Menjalankan model TensorFlow Lite secara on-device (tahap 7 pada alur PDF).
/// Dipilih otomatis lewat conditional import di ml_service.dart.
///
/// MODE MOCK: jika food_model.tflite belum ada / gagal dimuat, kelas ini
/// otomatis jatuh ke klasifikasi "palsu" (deterministik dari isi gambar)
/// supaya seluruh alur aplikasi tetap bisa dites tanpa model asli.
/// Ganti [_useMock] jadi false secara otomatis begitu model asli berhasil dimuat.

class ClassificationResult {
  final String label;
  final double confidence;
  final bool isMock;
  ClassificationResult(this.label, this.confidence, {this.isMock = false});
}

class MLService {
  static Interpreter? _interpreter;
  static List<String> _labels = [];
  static const int inputSize = 224; // sesuai ukuran input model food_model.tflite

  /// Memuat model & label sekali saat aplikasi start (dipanggil dari splash screen).
  static Future<void> loadModel() async {
    // Label tetap dimuat walau model belum ada, supaya mode mock bisa
    // memilih dari daftar label yang sama seperti mode asli.
    try {
      final labelData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelData
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (_) {
      _labels = ['ayam_goreng', 'gado_gado', 'nasi_goreng',
        'nasi_padang', 'tempe_goreng'];
    }

    try {
      _interpreter = await Interpreter.fromAsset('assets/models/food_model.tflite');
    } catch (e) {
      // Model belum ada / masih placeholder -> aplikasi tetap berjalan
      // dalam MODE MOCK (lihat classifyImage).
      _interpreter = null;
    }
  }

  static bool get isModelLoaded => _interpreter != null;

  /// Melakukan preprocessing + inferensi pada byte gambar hasil foto/galeri.
  /// Jika model asli belum tersedia, mengembalikan hasil MOCK (bukan AI
  /// sungguhan) agar alur scan -> hasil analisis tetap bisa dites.
  static Future<ClassificationResult> classifyImage(Uint8List bytes) async {
    if (_interpreter == null) {
      return _mockClassify(bytes);
    }

    // 1. Decode & resize gambar sesuai input model
    final rawImage = img.decodeImage(bytes);
    if (rawImage == null) throw Exception('Gagal membaca gambar.');
    final resized = img.copyResize(rawImage, width: inputSize, height: inputSize);

    // 2. Normalisasi piksel ke [-1, 1] (SESUAI preprocessing MobileNetV2 di
    //    train_model.py/predict_tflite.py milik model ini: (pixel/127.5) - 1.0)
    //    dan susun tensor input [1, size, size, 3]
    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              (pixel.r / 127.5) - 1.0,
              (pixel.g / 127.5) - 1.0,
              (pixel.b / 127.5) - 1.0,
            ];
          },
        ),
      ),
    );

    // 3. Siapkan output tensor sesuai jumlah kelas (label) pada model
    final output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

    // 4. Jalankan inferensi
    _interpreter!.run(input, output);

    // 5. Ambil kelas dengan probabilitas tertinggi (argmax)
    final scores = (output[0] as List<double>);
    int bestIndex = 0;
    double bestScore = scores[0];
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestScore = scores[i];
        bestIndex = i;
      }
    }

    return ClassificationResult(_labels[bestIndex], bestScore);
  }

  /// Klasifikasi PALSU (bukan AI): memilih label berdasarkan ukuran file
  /// gambar supaya hasilnya konsisten untuk foto yang sama, tanpa perlu
  /// model .tflite sungguhan. HANYA untuk keperluan uji coba tampilan.
  static ClassificationResult _mockClassify(Uint8List bytes) {
    final labels = _labels.isNotEmpty
        ? _labels
        : ['ayam_goreng', 'gado_gado', 'nasi_goreng',
            'nasi_padang', 'tempe_goreng'];
    final index = bytes.length % labels.length;
    const mockConfidence = 0.87;
    return ClassificationResult(labels[index], mockConfidence, isMock: true);
  }

  static void dispose() {
    _interpreter?.close();
  }
}
