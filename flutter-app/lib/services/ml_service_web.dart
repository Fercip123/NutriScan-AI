import 'dart:typed_data';
import 'package:flutter/services.dart';

/// Versi WEB dari MLService.
///
/// tflite_flutter menggunakan dart:ffi yang TIDAK didukung di Flutter Web,
/// sehingga file ini sengaja tidak meng-import tflite_flutter maupun dart:io.
/// Dipilih otomatis saat build/run target web (lihat ml_service.dart).
///
/// MODE MOCK: karena TFLite tidak bisa jalan di web sama sekali, versi ini
/// SELALU memakai klasifikasi palsu (deterministik dari ukuran gambar)
/// supaya alur scan -> hasil analisis tetap bisa dites langsung di browser.

class ClassificationResult {
  final String label;
  final double confidence;
  final bool isMock;
  ClassificationResult(this.label, this.confidence, {this.isMock = false});
}

class MLService {
  static List<String> _labels = [];

  static Future<void> loadModel() async {
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
  }

  static bool get isModelLoaded => false;

  static Future<ClassificationResult> classifyImage(Uint8List bytes) async {
    final labels = _labels.isNotEmpty
        ? _labels
        : ['ayam_goreng', 'gado_gado', 'nasi_goreng',
            'nasi_padang', 'tempe_goreng'];
    final index = bytes.length % labels.length;
    const mockConfidence = 0.87;
    return ClassificationResult(labels[index], mockConfidence, isMock: true);
  }

  static void dispose() {}
}
