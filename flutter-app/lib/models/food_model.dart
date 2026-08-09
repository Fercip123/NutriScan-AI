/// Parsing angka yang aman: menerima int, double, String, atau null,
/// tanpa pernah melempar error.
double _toDouble(dynamic value, [double fallback = 0]) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

int _toIntSafe(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? fallback;
  return fallback;
}

class FoodResult {
  final int? foodId;
  final String label;
  final String name;
  final String? imageUrl;
  final int portionG;
  final double confidence;
  final double calorieKcal;
  final double carbsG;
  final double proteinG;
  final double fatG;
  final double fiberG;
  final double sugarG;
  final double sodiumMg;
  final String healthScore;
  final String? healthNote;

  FoodResult({
    this.foodId,
    required this.label,
    required this.name,
    this.imageUrl,
    required this.portionG,
    required this.confidence,
    required this.calorieKcal,
    required this.carbsG,
    required this.proteinG,
    required this.fatG,
    required this.fiberG,
    required this.sugarG,
    required this.sodiumMg,
    required this.healthScore,
    this.healthNote,
  });
}

class HistoryItem {
  final int id;
  final String foodName;
  final String? imagePath;
  final double calorieKcal;
  final DateTime scannedAt;

  HistoryItem({
    required this.id,
    required this.foodName,
    this.imagePath,
    required this.calorieKcal,
    required this.scannedAt,
  });

  /// Membuat HistoryItem dari baris database lokal (sqflite).
  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: _toIntSafe(map['id']),
      foodName: map['food_name']?.toString() ?? '',
      imagePath: map['image_path']?.toString(),
      calorieKcal: _toDouble(map['calorie_kcal']),
      scannedAt: DateTime.tryParse(map['scanned_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
