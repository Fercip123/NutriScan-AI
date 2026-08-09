import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/history_screen.dart';
import '../screens/tips_screen.dart';
import '../screens/profile_screen.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    late Widget page;
    switch (index) {
      case 0:
        page = const DashboardScreen();
        break;
      case 1:
        page = const HistoryScreen();
        break;
      case 2:
        page = const TipsScreen();
        break;
      default:
        page = const ProfileScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4CAF50);

    Widget item(IconData icon, String label, int index) {
      final active = currentIndex == index;
      return Expanded(
        child: InkWell(
          onTap: () => _navigate(context, index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: active ? green : Colors.black38, size: 24),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    color: active ? green : Colors.black38,
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  )),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            item(Icons.home_rounded, 'Beranda', 0),
            item(Icons.access_time_rounded, 'Riwayat', 1),
            item(Icons.lightbulb_outline_rounded, 'Tips', 2),
            item(Icons.person_outline_rounded, 'Profil', 3),
          ],
        ),
      ),
    );
  }
}
