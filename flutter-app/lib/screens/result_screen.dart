import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../services/history_db_service.dart';
import 'dashboard_screen.dart';

/// Halaman Hasil Analisis. Memakai Uint8List untuk gambar (bukan dart:io File)
/// agar berjalan di Android, iOS, Desktop, MAUPUN Flutter Web.
class ResultScreen extends StatefulWidget {
  final FoodResult food;
  final Uint8List? imageBytes;
  final bool isMock;

  const ResultScreen({
    super.key,
    required this.food,
    this.imageBytes,
    this.isMock = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _saving = false;
  bool _saved = false;

  Future<void> _saveToHistory() async {
    setState(() => _saving = true);
    // Data gizi hasil analisis disimpan ke database lokal (SQLite) di HP.
    final ok = await HistoryDbService.saveHistory(widget.food);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _saved = ok;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Tersimpan ke riwayat.' : 'Gagal menyimpan riwayat.')),
    );
  }

  Color _healthColor(String score) {
    switch (score) {
      case 'Baik':
        return const Color(0xFF4CAF50);
      case 'Kurang':
        return Colors.redAccent;
      default:
        return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Analisis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (route) => false,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isMock)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mode Uji Coba: hasil ini BUKAN dari AI sungguhan (model .tflite belum tersedia).',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: widget.imageBytes != null
                      ? Image.memory(widget.imageBytes!,
                          width: 72, height: 72, fit: BoxFit.cover)
                      : Container(
                          width: 72, height: 72, color: const Color(0xFFEFF6EE),
                          child: const Icon(Icons.restaurant, color: Color(0xFF4CAF50)),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(food.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('1 porsi (±${food.portionG} g)',
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6EE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Tingkat Keyakinan: ${(food.confidence * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              color: Color(0xFF4CAF50), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Informasi Gizi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _nutrientRow(Icons.local_fire_department, Colors.deepOrange, 'Kalori',
                '${food.calorieKcal.toStringAsFixed(0)} kkal'),
            _nutrientRow(Icons.grain, Colors.green, 'Karbohidrat',
                '${food.carbsG.toStringAsFixed(0)} g'),
            _nutrientRow(Icons.fitness_center, Colors.indigo, 'Protein',
                '${food.proteinG.toStringAsFixed(0)} g'),
            _nutrientRow(Icons.water_drop, Colors.amber, 'Lemak',
                '${food.fatG.toStringAsFixed(0)} g'),
            _nutrientRow(Icons.eco, Colors.teal, 'Serat',
                '${food.fiberG.toStringAsFixed(1)} g'),
            _nutrientRow(Icons.icecream, Colors.pink, 'Gula',
                '${food.sugarG.toStringAsFixed(0)} g'),
            _nutrientRow(Icons.grain_outlined, Colors.blueGrey, 'Natrium',
                '${food.sodiumMg.toStringAsFixed(0)} mg'),
            const SizedBox(height: 24),
            const Text('Penilaian Kesehatan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _healthColor(food.healthScore).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    food.healthScore == 'Baik'
                        ? Icons.sentiment_satisfied_alt
                        : food.healthScore == 'Kurang'
                            ? Icons.sentiment_dissatisfied
                            : Icons.sentiment_neutral,
                    color: _healthColor(food.healthScore),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(food.healthScore,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _healthColor(food.healthScore))),
                        const SizedBox(height: 4),
                        Text(food.healthNote ?? '-',
                            style: const TextStyle(color: Colors.black87)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_saving || _saved) ? null : _saveToHistory,
                child: _saving
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_saved ? 'Tersimpan' : 'Simpan ke Riwayat'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutrientRow(IconData icon, Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
