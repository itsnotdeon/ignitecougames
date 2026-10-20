import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/html_legacy_content.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';

class KartuTalkScreen extends StatefulWidget {
  const KartuTalkScreen({super.key});

  @override
  State<KartuTalkScreen> createState() => _KartuTalkScreenState();
}

class _KartuTalkScreenState extends State<KartuTalkScreen> {
  final Random _random = Random();
  static const String _customKey = 'ignite_html_kartu_talk_custom_topics';
  int _index = 0;
  bool _explicitMode = false;
  List<String> _customTopics = <String>[];

  @override
  void initState() {
    super.initState();
    _loadCustomTopics();
  }

  Future<void> _loadCustomTopics() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _customTopics = prefs.getStringList(_customKey) ?? <String>[]);
  }

  Future<void> _addCustomTopic() async {
    final controller = TextEditingController();
    final topic = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah topik custom'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Tulis pertanyaan atau topik obrolan…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (topic == null || topic.trim().isEmpty || !mounted) return;
    final normalized = topic.trim();
    if (_customTopics.any((item) => item.toLowerCase() == normalized.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Topik yang sama sudah ada.')),
      );
      return;
    }
    final updated = [..._customTopics, normalized];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_customKey, updated);
    if (mounted) setState(() => _customTopics = updated);
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<AppProvider>().isAfterDark;
    final topics = _explicitMode ? _customTopics : HtmlLegacyContent.cards;
    final hasTopic = topics.isNotEmpty;
    final topic = hasTopic ? topics[_index % topics.length] : null;
    final primary = dark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final text = dark ? AppColors.darkText : AppColors.normalText;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Kartu Talk')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Pilih kartu untuk membuka percakapan. Kalian boleh melewati pertanyaan kapan saja; tidak ada kewajiban menjawab.',
            style: TextStyle(
              color: dark ? AppColors.darkTextMuted : AppColors.normalTextMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('🃏 Kartu Biasa')),
              ButtonSegment(value: true, label: Text('🔥 Eksplisit / Custom')),
            ],
            selected: {_explicitMode},
            onSelectionChanged: (selection) => setState(() {
              _explicitMode = selection.first;
              _index = 0;
            }),
          ),
          const SizedBox(height: 18),
          Container(
            constraints: const BoxConstraints(minHeight: 245),
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? const [Color(0xFF35142B), Color(0xFF1A1026)]
                    : const [Color(0xFFFFE4EA), Color(0xFFFFF7E9)],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: dark ? AppColors.darkBorder : AppColors.normalBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _explicitMode ? 'TOPIK CUSTOM' : 'KARTU BIASA',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  topic ?? 'Belum ada topik custom. Tambahkan topik pertama kalian untuk mulai bermain.',
                  style: TextStyle(
                    color: text,
                    fontSize: 22,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  hasTopic ? 'Kartu ${_index + 1} dari ${topics.length}' : 'Konten custom',
                  style: TextStyle(
                    color: dark ? AppColors.darkTextMuted : AppColors.normalTextMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_explicitMode)
            FilledButton.icon(
              onPressed: _addCustomTopic,
              icon: const Icon(Icons.add),
              label: const Text('Tambah topik custom'),
            )
          else
            FilledButton.icon(
              onPressed: () => setState(() => _index = (_index + 1) % topics.length),
              icon: const Icon(Icons.shuffle),
              label: const Text('Kartu berikutnya'),
            ),
          if (_explicitMode && _customTopics.isNotEmpty) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove(_customKey);
                if (mounted) setState(() { _customTopics = <String>[]; _index = 0; });
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Hapus semua topik custom'),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            _explicitMode
                ? 'Topik custom tersimpan lokal di perangkat ini. Kategori eksplisit bawaan HTML awalnya kosong; konten di sini tidak diganti dengan topik biasa.'
                : 'Kartu biasa diambil dari kumpulan pertanyaan HTML IGNITE yang diberikan.',
            style: TextStyle(
              color: dark ? AppColors.darkTextMuted : AppColors.normalTextMuted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}