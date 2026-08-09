import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/food_model.dart';

/// Service database lokal (SQLite via sqflite) untuk menyimpan riwayat
/// pindaian di HP, menggantikan endpoint backend `history/*.php`.
/// Semua data tersimpan di penyimpanan internal aplikasi, tidak butuh
/// server/internet sama sekali.
class HistoryDbService {
  static Database? _db;

  static Future<Database> _getDb() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nutriscan_local.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            food_label TEXT,
            food_name TEXT,
            image_path TEXT,
            portion_g INTEGER,
            confidence REAL,
            calorie_kcal REAL,
            carbs_g REAL,
            protein_g REAL,
            fat_g REAL,
            fiber_g REAL,
            sugar_g REAL,
            sodium_mg REAL,
            health_score TEXT,
            scanned_at TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  /// Menyimpan hasil analisis makanan ke riwayat lokal.
  static Future<bool> saveHistory(FoodResult food, {String? imagePath}) async {
    try {
      final db = await _getDb();
      await db.insert('history', {
        'food_label': food.label,
        'food_name': food.name,
        'image_path': imagePath,
        'portion_g': food.portionG,
        'confidence': food.confidence,
        'calorie_kcal': food.calorieKcal,
        'carbs_g': food.carbsG,
        'protein_g': food.proteinG,
        'fat_g': food.fatG,
        'fiber_g': food.fiberG,
        'sugar_g': food.sugarG,
        'sodium_mg': food.sodiumMg,
        'health_score': food.healthScore,
        'scanned_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Mengambil seluruh riwayat, terbaru lebih dulu.
  static Future<List<HistoryItem>> getHistory() async {
    final db = await _getDb();
    final rows = await db.query('history', orderBy: 'scanned_at DESC');
    return rows.map((r) => HistoryItem.fromMap(r)).toList();
  }

  /// Menghapus seluruh riwayat lokal.
  static Future<bool> deleteAllHistory() async {
    try {
      final db = await _getDb();
      await db.delete('history');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Menghitung ringkasan sederhana (rata-rata kalori/hari, jumlah pindaian,
  /// skor kesehatan) dari riwayat lokal, menggantikan `history/summary.php`.
  static Future<Map<String, dynamic>> getSummary() async {
    final db = await _getDb();
    final rows = await db.query('history');

    if (rows.isEmpty) {
      return {
        'avg_calorie_per_day': 0,
        'scan_count': 0,
        'health_score': 0,
        'health_label': '-',
      };
    }

    final Map<String, double> caloriesByDay = {};
    int goodCount = 0;
    for (final r in rows) {
      final scannedAt = DateTime.tryParse(r['scanned_at'] as String? ?? '') ?? DateTime.now();
      final dayKey = '${scannedAt.year}-${scannedAt.month}-${scannedAt.day}';
      final cal = (r['calorie_kcal'] as num?)?.toDouble() ?? 0;
      caloriesByDay[dayKey] = (caloriesByDay[dayKey] ?? 0) + cal;
      if (r['health_score'] == 'Baik') goodCount++;
    }

    final avgCalorie = caloriesByDay.values.reduce((a, b) => a + b) / caloriesByDay.length;
    final healthPct = ((goodCount / rows.length) * 100).round();
    final String healthLabel;
    if (healthPct >= 70) {
      healthLabel = 'Baik';
    } else if (healthPct >= 40) {
      healthLabel = 'Sedang';
    } else {
      healthLabel = 'Perlu Perhatian';
    }

    return {
      'avg_calorie_per_day': avgCalorie.round(),
      'scan_count': rows.length,
      'health_score': healthPct,
      'health_label': healthLabel,
    };
  }
}
