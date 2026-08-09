import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class TipItem {
  final String title;
  final String desc;
  final IconData icon;
  final String category;
  const TipItem(this.title, this.desc, this.icon, this.category);
}

const List<TipItem> _tips = [
  TipItem('Pentingnya Sarapan',
      'Sarapan membantu meningkatkan konsentrasi dan energi sepanjang hari.',
      Icons.wb_sunny_outlined, 'Nutrisi'),
  TipItem('Perbanyak Serat',
      'Serat baik untuk pencernaan dan membantu menjaga berat badan ideal.',
      Icons.eco_outlined, 'Nutrisi'),
  TipItem('Minum Air Putih',
      'Minum 8 gelas air per hari untuk menjaga tubuh tetap terhidrasi.',
      Icons.water_drop_outlined, 'Aktivitas'),
  TipItem('Batasi Gula & Garam',
      'Konsumsi gula dan garam berlebih dapat meningkatkan risiko penyakit.',
      Icons.icecream_outlined, 'Diet'),
];

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  String _selectedCategory = 'Semua';
  final _searchCtrl = TextEditingController();

  List<TipItem> get _filteredTips {
    return _tips.where((tip) {
      final matchCategory = _selectedCategory == 'Semua' || tip.category == _selectedCategory;
      final matchSearch = _searchCtrl.text.isEmpty ||
          tip.title.toLowerCase().contains(_searchCtrl.text.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const categories = ['Semua', 'Nutrisi', 'Diet', 'Aktivitas'];

    return Scaffold(
      appBar: AppBar(title: const Text('Tips Sehat')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari tips kesehatan...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF1F4F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: categories.map((cat) {
                final selected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    selectedColor: const Color(0xFF4CAF50),
                    labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: _filteredTips.length,
              itemBuilder: (context, index) {
                final tip = _filteredTips[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6EE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(tip.icon, color: const Color(0xFF4CAF50)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tip.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(tip.desc, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }
}
