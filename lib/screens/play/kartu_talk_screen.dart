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
    final muted = dark ? AppColors.darkTextMuted : AppColors.normalTextMuted;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Kartu Talk')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Satu kartu, satu percakapan yang lebih dekat.',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kalian boleh melewati pertanyaan kapan saja; tidak ada kewajiban menjawab.',
                      style: TextStyle(color: muted, height: 1.5),
                    ),
                    const SizedBox(height: 20),
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
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      constraints: const BoxConstraints(minHeight: 280),
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: dark
                              ? const [Color(0xFF442038), Color(0xFF211326), Color(0xFF17101E)]
                              : const [Color(0xFFFFDDE5), Color(0xFFFFEEF0), Color(0xFFF9E4D8)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: primary.withValues(alpha: 0.28)),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: dark ? 0.10 : 0.07),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.favorite_rounded, color: primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _explicitMode ? 'TOPIK CUSTOM' : 'KARTU BIASA',
                                style: TextStyle(color: primary, fontWeight: FontWeight.w800, letterSpacing: 1.6, fontSize: 11),
                              ),
                              const Spacer(),
                              const Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.gold),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Text(
                            topic ?? 'Belum ada topik custom. Tambahkan topik pertama kalian untuk mulai bermain.',
                            style: TextStyle(color: text, fontSize: 22, height: 1.4, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            hasTopic ? 'Kartu ${_index + 1} dari ${topics.length}' : 'Belum ada konten custom',
                            style: TextStyle(color: muted, fontSize: 12),
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
                        onPressed: hasTopic ? () => setState(() => _index = _random.nextInt(topics.length)) : null,
                        icon: const Icon(Icons.shuffle_rounded),
                        label: const Text('Ambil kartu berikutnya'),
                      ),
                    if (_explicitMode && _customTopics.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove(_customKey);
                          if (mounted) setState(() { _customTopics = <String>[]; _index = 0; });
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Hapus semua topik custom'),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (dark ? AppColors.darkCard : AppColors.normalCard).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: dark ? AppColors.darkBorder : AppColors.normalBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 18, color: muted),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _explicitMode
                                  ? 'Topik custom tersimpan lokal di perangkat ini. Kategori eksplisit bawaan HTML awalnya kosong; konten tidak diganti dengan topik biasa.'
                                  : 'Kartu biasa menggunakan kumpulan pertanyaan dari HTML IGNITE yang diberikan.',
                              style: TextStyle(color: muted, fontSize: 12, height: 1.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
