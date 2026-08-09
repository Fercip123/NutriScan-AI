import 'package:flutter/material.dart';
import '../services/ml_service.dart';
import '../services/food_database_service.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Muat model TensorFlow Lite dan database gizi lokal di awal agar siap
    // saat halaman scan dibuka. Semuanya berjalan tanpa server/internet.
    await MLService.loadModel();
    await FoodDatabaseService.loadDatabase();

    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 800));

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 56),
            ),
            const SizedBox(height: 24),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                children: [
                  TextSpan(text: 'NutriScan '),
                  TextSpan(text: 'AI', style: TextStyle(color: Color(0xFF4CAF50))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pindai makanan, kenali gizi,\njaga kesehatan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Color(0xFF4CAF50)),
          ],
        ),
      ),
    );
  }
}
