import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import 'scan_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.search, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 20),
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
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  color: const Color(0xFFEFF6EE),
                  child: const Icon(Icons.ramen_dining_rounded,
                      size: 90, color: Color(0xFF4CAF50)),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ScanScreen()),
                  ),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Mulai Pindai',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
}
