import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ml_service.dart';
import '../services/food_database_service.dart';
import 'result_screen.dart';

/// Halaman kamera untuk memindai makanan (tahap 6: Integrasi Kamera).
/// Menggunakan Uint8List (bytes) alih-alih dart:io File agar kompatibel
/// dengan Android, iOS, Desktop, MAUPUN Flutter Web.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _processing = false;

  Future<void> _pickAndAnalyze(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _processing = true);

    try {
      final Uint8List bytes = await picked.readAsBytes();

      // Tahap 7: Integrasi AI - inferensi TensorFlow Lite on-device
      final classification = await MLService.classifyImage(bytes);

      // Pengambilan Data Gizi dari database lokal (JSON) berdasarkan label AI
      final food = await FoodDatabaseService.lookup(
        label: classification.label,
        confidence: classification.confidence,
      );

      if (!mounted) return;
      setState(() => _processing = false);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            food: food,
            imageBytes: bytes,
            isMock: classification.isMock,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _processing = false);
      // Tampilkan pesan error ASLI (dari backend/koneksi/AI), bukan teks
      // generik, supaya penyebabnya jelas.
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('NutriScan AI'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      color: Colors.grey[900],
                      height: 380,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: _processing
                          ? const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: Color(0xFF4CAF50)),
                                SizedBox(height: 16),
                                Text('Menganalisis makanan...',
                                    style: TextStyle(color: Colors.white70)),
                              ],
                            )
                          : const Icon(Icons.restaurant_rounded,
                              size: 80, color: Colors.white24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Arahkan kamera ke makanan\npastikan terlihat jelas',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _iconLabel(Icons.photo_library_outlined, 'Galeri',
                    () => _pickAndAnalyze(ImageSource.gallery)),
                GestureDetector(
                  onTap: _processing ? null : () => _pickAndAnalyze(ImageSource.camera),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
                  ),
                ),
                _iconLabel(Icons.flash_off_outlined, 'Flash', () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconLabel(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
