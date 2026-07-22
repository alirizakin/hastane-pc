import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // === Renkler ===
  static const _kirmizi = Color(0xFFD32F2F);
  static const _turkuaz = Color(0xFF00BFA5);
  static const _koyuKirmizi = Color(0xFFB71C1C);
  static const _acikKirmiziBg = Color(0xFFFFF5F5);
  static const _griButton = Color(0xFFF5F5F5);
  static const _griBorder = Color(0xFFE0E0E0);
  static const _yaziKoyu = Color(0xFF212121);

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

  // === Link Açma İşlemleri ===

  Future<void> _chromeLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _snack('Tarayıcı açılamadı: $url');
    }
  }

  Future<void> _explorerPath(String uncPath) async {
    // Windows'ta UNC yolunu explorer.exe ile aç
    try {
      await Process.run('explorer', [uncPath]);
    } catch (_) {
      _snack('Klasör açılamadı: $uncPath');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _kirmizi,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onCalisanGorus() => _chromeLink(
      'https://ispartasehir.saglik.gov.tr/Form-TR/4326/calisan-gorus-ve-oneri-formu.html');

  void _onRandevu() => _chromeLink(
      'https://ispartasehir.saglik.gov.tr/Form-TR/4900/calisan-personeller-icin-yonetimden-randevu-alma.html');

  void _onNobet() => _explorerPath(
      r'\\ishfp01\Deploy\DesktopForHBYS\KALİTE DÖKÜMAN\NÖBET LİSTELERİ');

  void _onKlinik() => _explorerPath(
      r'\\ishfp01\Deploy\DesktopForHBYS\KALİTE DÖKÜMAN\Klinik Rehber ve Protokoller');

  void _onHbys() =>
      _explorerPath(r'\\ishfp01\Deploy\DesktopForHBYS');

  void _onAkgun() => _chromeLink('https://hbys.ish.local/hbys-web/');

  void _onDys() => _chromeLink('https://dys.saglik.gov.tr/');

  void _onSbPosta() =>
      _chromeLink('https://eposta.saglik.gov.tr/owakontrol/');

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isWide = screenW > 700;
    final dateLabel =
        '${_menuDay.day.toString().padLeft(2, '0')}.${_menuDay.month.toString().padLeft(2, '0')}.${_menuDay.year} ${_turkishDayName(_menuDay.weekday)}';
    final menu = _todayMenu;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // === ÜST BAŞLIK ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_koyuKirmizi, _kirmizi],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  Image.asset('assets/images/arma_logo.jpg',
                      width: 56, height: 56, errorBuilder: (_, __, ___) =>
                      const Icon(Icons.local_hospital, color: Colors.white, size: 36)),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ISPARTA ŞEHİR HASTANESİ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'ASİSTAN',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 5,
                        ),
                      ),
                    ],
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
                        SizedBox(
                          width: 340,
                          child: _buildLeftColumn(),
                        ),
                        Container(width: 1, color: _griBorder),
                        Expanded(child: _buildRightColumn(dateLabel, menu)),
                      ],
                    )
                  : ListView(
                      children: [
                        _buildLeftColumn(),
                        const Divider(height: 1, color: _griBorder),
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Personel İşlemleri',
            [
              _MenuItem('Çalışan Görüş ve Öneri Formu',
                  Icons.feedback_outlined, _onCalisanGorus),
              _MenuItem('Çalışan Personeller İçin\nYönetimden Randevu Alma',
                  Icons.calendar_today_outlined, _onRandevu),
            ],
          ),
          const SizedBox(height: 18),
          _buildSection(
            'Kısayol',
            [
              _MenuItem('Nöbet Listeleri', Icons.list_alt_rounded, _onNobet),
              _MenuItem('Klinik Rehber ve\nProtokoller', Icons.menu_book_rounded, _onKlinik),
              _MenuItem('Hbys Dosyalar', Icons.folder_outlined, _onHbys),
              _MenuItem('Akgün HBYS', Icons.computer_rounded, _onAkgun),
              _MenuItem('DYS', Icons.description_outlined, _onDys),
              _MenuItem('SB POSTA', Icons.mail_outline_rounded, _onSbPosta),
            ],
          ),
          const SizedBox(height: 18),
          // Logo alt kısım
          Center(
            child: Image.asset('assets/images/arma_logo.jpg',
                width: 80, height: 80, errorBuilder: (_, __, ___) =>
                const SizedBox.shrink()),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _griBorder),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
            decoration: const BoxDecoration(
              color: _kirmizi,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(9),
                topRight: Radius.circular(9),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4, height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Section items
          ...items.map((item) => _buildMenuItemButton(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildMenuItemButton(_MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _griBorder.withOpacity(0.5))),
        ),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFFBE9E7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, size: 18, color: _kirmizi),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  color: _yaziKoyu,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // === SAĞ KOLON ===
  Widget _buildRightColumn(String dateLabel, _MealItems? menu) {
    return Container(
      margin: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _griBorder),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Yemek Listesi başlık
          Container(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
            decoration: BoxDecoration(
              color: _kirmizi.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
              border: Border(bottom: BorderSide(color: _griBorder)),
            ),
            child: Row(
              children: [
                const Icon(Icons.restaurant_menu_rounded,
                    color: _kirmizi, size: 22),
                const SizedBox(width: 10),
                const Text(
                  'YEMEK LİSTESİ',
                  style: TextStyle(
                    color: _koyuKirmizi,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  dateLabel,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Yemek içeriği
          Expanded(
            child: _menuLoading
                ? const Center(child: CircularProgressIndicator(color: _kirmizi))
                : _menuError != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text('Menü yüklenemedi',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
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
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            children: [
                              _buildMealRow('Sabah', Icons.free_breakfast_rounded, menu.breakfast),
                              const Divider(height: 20, color: _griBorder),
                              _buildMealRow('Öğle', Icons.lunch_dining_rounded, menu.lunch),
                              const Divider(height: 20, color: _griBorder),
                              _buildMealRow('Akşam', Icons.dinner_dining_rounded, menu.dinner),
                            ],
                          ),
          ),

          // Alt navigasyon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              border: Border(top: BorderSide(color: _griBorder)),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(11),
                bottomRight: Radius.circular(11),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => _menuDay = _menuDay.subtract(const Duration(days: 1))),
                  icon: const Icon(Icons.chevron_left, size: 20, color: _kirmizi),
                  label: const Text('Önceki', style: TextStyle(fontSize: 12, color: _kirmizi)),
                ),
                TextButton.icon(
                  onPressed: _loadMenus,
                  icon: const Icon(Icons.refresh, size: 18, color: _turkuaz),
                  label: const Text('Yenile', style: TextStyle(fontSize: 12, color: _turkuaz)),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _menuDay = _menuDay.add(const Duration(days: 1))),
                  icon: const Icon(Icons.chevron_right, size: 20, color: _kirmizi),
                  label: const Text('Sonraki', style: TextStyle(fontSize: 12, color: _kirmizi)),
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
          width: 38, height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_kirmizi, _koyuKirmizi]),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: _kirmizi.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _yaziKoyu,
                  )),
              const SizedBox(height: 6),
              if (items.isEmpty)
                Text('Veri yok',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13))
              else
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 5, height: 5,
                            decoration: const BoxDecoration(
                              color: _kirmizi,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(item,
                                style: const TextStyle(fontSize: 13, height: 1.35, color: Color(0xFF424242))),
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
  final VoidCallback onTap;
  _MenuItem(this.label, this.icon, this.onTap);
}