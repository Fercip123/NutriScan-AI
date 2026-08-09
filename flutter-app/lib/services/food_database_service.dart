import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/food_model.dart';

/// Service database gizi 100% LOKAL (tidak butuh internet/server).
/// Mengambil data dari assets/models/nutrition_db.json yang sudah dibundel
/// di dalam aplikasi, menggantikan endpoint backend `foods/classify.php`.
class FoodDatabaseService {
  static Map<String, dynamic>? _data;

  /// Memuat database gizi sekali saat aplikasi start (dipanggil dari splash screen).
  static Future<void> loadDatabase() async {
    if (_data != null) return;
    try {
      final raw = await rootBundle.loadString('assets/models/nutrition_db.json');
      _data = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      _data = {};
    }
  }

  /// Menentukan skor kesehatan sederhana berdasarkan kadar lemak & natrium.
  static String _healthScoreOf(double fatG, double sodiumMg) {
    if (fatG <= 12 && sodiumMg <= 500) return 'Baik';
    if (fatG >= 20 || sodiumMg >= 800) return 'Kurang';
    return 'Sedang';
  }

  static int _extractPortionG(String? porsi) {
    if (porsi == null) return 100;
    final match = RegExp(r'(\d+)\s*g').firstMatch(porsi);
    if (match != null) return int.tryParse(match.group(1)!) ?? 100;
    return 100;
  }

  /// Mencari data gizi berdasarkan label hasil klasifikasi AI (on-device),
  /// sepenuhnya dari database lokal. Melempar Exception jika label tidak
  /// ditemukan, sama seperti perilaku backend sebelumnya.
  static Future<FoodResult> lookup({
    required String label,
    required double confidence,
    int? portionG,
  }) async {
    await loadDatabase();
    final entry = _data?[label] as Map<String, dynamic>?;

    if (entry == null) {
      throw Exception('Makanan "$label" tidak ditemukan dalam database gizi lokal.');
    }

    final fatG = (entry['lemak_g'] as num?)?.toDouble() ?? 0;
    final sodiumMg = (entry['natrium_mg'] as num?)?.toDouble() ?? 0;

    return FoodResult(
      label: label,
      name: entry['nama']?.toString() ?? label,
      portionG: portionG ?? _extractPortionG(entry['porsi']?.toString()),
      confidence: confidence,
      calorieKcal: (entry['kalori_kcal'] as num?)?.toDouble() ?? 0,
      carbsG: (entry['karbohidrat_g'] as num?)?.toDouble() ?? 0,
      proteinG: (entry['protein_g'] as num?)?.toDouble() ?? 0,
      fatG: fatG,
      fiberG: (entry['serat_g'] as num?)?.toDouble() ?? 0,
      sugarG: (entry['gula_g'] as num?)?.toDouble() ?? 0,
      sodiumMg: sodiumMg,
      healthScore: _healthScoreOf(fatG, sodiumMg),
      healthNote: entry['catatan_sehat']?.toString(),
    );
  }
}
