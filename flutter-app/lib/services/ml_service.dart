/// Entry point MLService.
///
/// Flutter otomatis memilih implementasi yang benar saat COMPILE TIME:
/// - Jika target punya dart:io (Android/iOS/Desktop) → pakai ml_service_native.dart
///   (menjalankan TensorFlow Lite via tflite_flutter/dart:ffi).
/// - Jika tidak (Web) → pakai ml_service_web.dart (tanpa dart:ffi sama sekali),
///   sehingga proses build web tidak pernah menyentuh kode tflite_flutter.
///
/// Import dari file ini di seluruh proyek (JANGAN import ml_service_native.dart
/// atau ml_service_web.dart secara langsung dari layar UI).
export 'ml_service_web.dart' if (dart.library.io) 'ml_service_native.dart';
