import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../services/history_db_service.dart';
import '../widgets/bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await ProfileService.getProfile();
    final summary = await HistoryDbService.getSummary();
    if (!mounted) return;
    setState(() {
      _user = user;
      _summary = summary;
      _loading = false;
    });
  }

  /// Parsing angka yang aman: menerima int, String, atau null, dan tidak
  /// pernah melempar error.
  int _toInt(dynamic value, int fallback) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final calorieGoal = _toInt(_user?['daily_calorie_goal'], 1500);
    final waterGoal = _toInt(_user?['daily_water_goal'], 8);
    final activityGoal = _toInt(_user?['daily_activity_goal'], 30);

    final avgCalorie = _toInt(_summary?['avg_calorie_per_day'], 0);
    final scanCount = _toInt(_summary?['scan_count'], 0);
    final healthScore = _toInt(_summary?['health_score'], 0);
    final healthLabel = _summary?['health_label'] ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFFEFF6EE),
                      child: Icon(Icons.eco, color: Color(0xFF4CAF50), size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Halo, ${_user?['name'] ?? 'Pengguna'} 👋',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        const Text('Jaga pola makan, raih hidup sehat!',
                            style: TextStyle(color: Colors.black54, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Ringkasan Minggu Ini',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _statCard('$avgCalorie', 'kkal/hari', 'Kalori Rata-rata'),
                    const SizedBox(width: 10),
                    _statCard('$scanCount', 'kali', 'Pindaian'),
                    const SizedBox(width: 10),
                    _statCard('$healthScore', healthLabel, 'Skor Kesehatan'),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Tujuan Harian',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                _goalBar('Kalori', avgCalorie, calorieGoal, 'kkal',
                    const Color(0xFF4CAF50)),
                const SizedBox(height: 14),
                _goalBar('Minum Air', 5, waterGoal, 'gelas', Colors.blue),
                const SizedBox(height: 14),
                _goalBar('Aktivitas', 20, activityGoal, 'menit', Colors.orange),
                const SizedBox(height: 28),
              ],
            ),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
    );
  }

  Widget _statCard(String value, String unit, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4F0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(unit, style: const TextStyle(fontSize: 11, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _goalBar(String label, int current, int goal, String unit, Color color) {
    final ratio = goal > 0 ? (current / goal).clamp(0, 1).toDouble() : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('$goal $unit', style: const TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: const Color(0xFFEDEDED),
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text('$current / $goal $unit', style: const TextStyle(fontSize: 11, color: Colors.black45)),
      ],
    );
  }
}
