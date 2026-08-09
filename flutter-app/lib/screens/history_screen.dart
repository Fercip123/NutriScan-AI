import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food_model.dart';
import '../services/history_db_service.dart';
import '../widgets/bottom_nav.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await HistoryDbService.getHistory();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Semua Riwayat?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true) {
      await HistoryDbService.deleteAllHistory();
      _load();
    }
  }

  Map<String, List<HistoryItem>> _groupByDay(List<HistoryItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<HistoryItem>> groups = {};
    for (final item in items) {
      final d = DateTime(item.scannedAt.year, item.scannedAt.month, item.scannedAt.day);
      String key;
      if (d == today) {
        key = 'Hari ini';
      } else if (d == yesterday) {
        key = 'Kemarin';
      } else {
        key = DateFormat('d MMMM yyyy', 'id_ID').format(d);
      }
      groups.putIfAbsent(key, () => []).add(item);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDay(_items);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pindaian'),
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: _clearAll),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : _items.isEmpty
              ? const Center(child: Text('Belum ada riwayat pindaian.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    children: grouped.entries.expand((entry) {
                      return [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(entry.key,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        ...entry.value.map((item) => _historyTile(item)),
                      ];
                    }).toList(),
                  ),
                ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }

  Widget _historyTile(HistoryItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 48, height: 48, color: const Color(0xFFEFF6EE),
              child: const Icon(Icons.restaurant, color: Color(0xFF4CAF50), size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.foodName, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${item.calorieKcal.toStringAsFixed(0)} kkal',
                    style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          Text(DateFormat('HH:mm').format(item.scannedAt),
              style: const TextStyle(color: Colors.black45, fontSize: 12)),
          const Icon(Icons.chevron_right, color: Colors.black26),
        ],
      ),
    );
  }
}
