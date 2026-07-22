import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // === Yemek Listesi ===
  static const String _jsonUrl =
      'https://raw.githubusercontent.com/alirizakin/hastane-uygulama/main/data/menu.json';
  bool _menuLoading = true;
  String? _menuError;
  DateTime _menuDay = DateTime.now();
  Map<String, _MealItems>? _allMenus;

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  Future<void> _loadMenus() async {
    if (!mounted) return;
    setState(() {
      _menuLoading = true;
      _menuError = null;
    });
    try {
      final response = await http.get(Uri.parse(_jsonUrl));
      if (response.statusCode != 200) {
        throw Exception('Menü indirilemedi: ${response.statusCode}');
      }
      final Map<String, dynamic> raw = json.decode(response.body);
      final parsed = <String, _MealItems>{};
      for (final entry in raw.entries) {
        final v = entry.value;
        if (v is Map<String, dynamic>) {
          parsed[entry.key] = _MealItems(
            breakfast: _strings(v['breakfast']),
            lunch: _strings(v['lunch']),
            dinner: _strings(v['dinner']),
          );
        }
      }
      if (!mounted) return;
      setState(() => _allMenus = parsed);
    } catch (e) {
      if (!mounted) return;
      setState(() => _menuError = e.toString());
    }
    if (!mounted) return;
    setState(() => _menuLoading = false);
  }

  List<String> _strings(dynamic v) {
    if (v is List) return v.cast<String>();
    return [];
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  _MealItems? get _todayMenu => _allMenus?[_dayKey(_menuDay)];

  String _turkishDayName(int weekday) {
    const days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    return days[weekday - 1];
  }

  // === Buton placeholder ===
  void _onButtonTap(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$label" butonu — link ve işlev henüz eklenmedi.'),
        backgroundColor: const Color(0xFF1565C0),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isWide = screenW > 800;
    final dateLabel =
        '${_menuDay.day.toString().padLeft(2, '0')}.${_menuDay.month.toString().padLeft(2, '0')}.${_menuDay.year} ${_turkishDayName(_menuDay.weekday)}';
    final menu = _todayMenu;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // === ÜST BAŞLIK ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF1565C0),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'ISPARTA ŞEHİR HASTANESİ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ASİSTAN',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),

            // === ANA İÇERİK ===
            Expanded(
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildLeftColumn()),
                        const VerticalDivider(width: 1, color: Color(0xFFBDBDBD)),
                        Expanded(child: _buildRightColumn(dateLabel, menu)),
                      ],
                    )
                  : ListView(
                      children: [
                        _buildLeftColumn(),
                        const Divider(height: 1, color: Color(0xFFBDBDBD)),
                        _buildRightColumn(dateLabel, menu),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // === SOL KOLON ===
  Widget _buildLeftColumn() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Personel İşlemleri',
            [
              _MenuItem('Çalışan Görüş ve Öneri Formu', Icons.feedback_outlined),
              _MenuItem('Çalışan Personeller İçin\nYönetimden Randevu Alma Formu', Icons.calendar_today_outlined),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Kısayol',
            [
              _MenuItem('Nöbet Listeleri', Icons.list_alt_rounded),
              _MenuItem('Klinik Rehber ve\nProtokoller', Icons.menu_book_rounded),
              _MenuItem('Hbys Dosyalar', Icons.folder_outlined),
              _MenuItem('Akgün HBYS', Icons.computer_rounded),
              _MenuItem('DYS', Icons.description_outlined),
              _MenuItem('SB POSTA', Icons.mail_outline_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFBBDEFB)),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1565C0),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: items
                .map((item) => _buildMenuItemButton(item))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItemButton(_MenuItem item) {
    return InkWell(
      onTap: () => _onButtonTap(item.label.replaceAll('\n', ' ')),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Row(
          children: [
            Icon(item.icon, size: 20, color: const Color(0xFF616161)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  color: Color(0xFF212121),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }

  // === SAĞ KOLON ===
  Widget _buildRightColumn(String dateLabel, _MealItems? menu) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Yemek Listesi başlık
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFE3F2FD),
              border: Border(bottom: BorderSide(color: Color(0xFFBDBDBD))),
            ),
            child: Row(
              children: [
                const Icon(Icons.restaurant_menu_rounded,
                    color: Color(0xFF1565C0), size: 22),
                const SizedBox(width: 10),
                const Text(
                  'YEMEK LİSTESİ',
                  style: TextStyle(
                    color: Color(0xFF1565C0),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  dateLabel,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Yemek içeriği
          Expanded(
            child: _menuLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)))
                : _menuError != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text('Menü yüklenemedi', style: TextStyle(color: Colors.grey.shade600)),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: _loadMenus,
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Tekrar Dene'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : menu == null
                        ? Center(
                            child: Text(
                              'Bugün için menü bulunamadı',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              _buildMealRow('Sabah', Icons.free_breakfast_rounded, menu.breakfast),
                              const Divider(height: 24),
                              _buildMealRow('Öğle', Icons.lunch_dining_rounded, menu.lunch),
                              const Divider(height: 24),
                              _buildMealRow('Akşam', Icons.dinner_dining_rounded, menu.dinner),
                            ],
                          ),
          ),

          // Alt navigasyon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() => _menuDay = _menuDay.subtract(const Duration(days: 1)));
                  },
                  icon: const Icon(Icons.chevron_left, size: 20),
                  label: const Text('Önceki', style: TextStyle(fontSize: 13)),
                ),
                TextButton.icon(
                  onPressed: _loadMenus,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Yenile', style: TextStyle(fontSize: 13)),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _menuDay = _menuDay.add(const Duration(days: 1)));
                  },
                  icon: const Icon(Icons.chevron_right, size: 20),
                  label: const Text('Sonraki', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealRow(String title, IconData icon, List<String> items) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  )),
              const SizedBox(height: 6),
              if (items.isEmpty)
                Text('Veri yok',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14))
              else
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1565C0),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(item, style: const TextStyle(fontSize: 14, height: 1.3)),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        ),
      ],
    );
  }
}

// === Yardımcı sınıflar ===
class _MealItems {
  final List<String> breakfast, lunch, dinner;
  _MealItems({required this.breakfast, required this.lunch, required this.dinner});
}

class _MenuItem {
  final String label;
  final IconData icon;
  _MenuItem(this.label, this.icon);
}