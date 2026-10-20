import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/html_legacy_content.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';

class IgniteRoleplayScreen extends StatefulWidget {
  const IgniteRoleplayScreen({super.key});

  @override
  State<IgniteRoleplayScreen> createState() => _IgniteRoleplayScreenState();
}

class _IgniteRoleplayScreenState extends State<IgniteRoleplayScreen> {
  final Random _random = Random();
  String _mode = 'Biasa';
  int _index = 0;
  bool _consented = false;
  String? _custom;

  final Map<String, List<String>> _scenarios = {
    'Biasa': List<String>.from(HtmlLegacyContent.roleplayChallenge),
    'Eksplisit': <String>[],
  };

  @override
  void initState() {
    super.initState();
    _loadImportedRoleplayItems();
  }

  Future<void> _loadImportedRoleplayItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('ignite_html_compatible_topics_snapshot');
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final normalItems = decoded['roleplayCustomItems'];
      final explicitItems = decoded['roleplayCustomItemsExplicit'];
      final normal = _roleplayItemsToPrompts(normalItems);
      final explicit = _roleplayItemsToPrompts(explicitItems);
      if (!mounted) return;
      setState(() {
        if (normal.isNotEmpty) _scenarios['Biasa']!.addAll(normal);
        if (explicit.isNotEmpty) _scenarios['Eksplisit']!.addAll(explicit);
      });
    } catch (_) {
      // Keep the source-derived built-in content if the optional import is malformed.
    }
  }

  List<String> _roleplayItemsToPrompts(dynamic value) {
    if (value is! List) return <String>[];
    return value.whereType<Map>().map((item) {
      final contextText = (item['context'] ?? '').toString().trim();
      final challengeText = (item['challenge'] ?? '').toString().trim();
      final roleName = (item['roleName'] ?? item['name'] ?? '').toString().trim();
      final prefix = roleName.isEmpty ? '' : '$roleName — ';
      return [if (contextText.isNotEmpty) contextText, if (challengeText.isNotEmpty) '$prefix$challengeText'].join('\n\n');
    }).where((prompt) => prompt.trim().isNotEmpty).toList();
  }

  Future<void> _writeCustomScenario() async {
    final controller = TextEditingController(text: _custom ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Skenario buatan kalian'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 5,
          maxLength: 700,
          decoration: const InputDecoration(
            hintText: 'Tulis konteks, peran, atau skenario yang kalian sepakati…',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('Gunakan skenario')),
        ],
      ),
    );
    controller.dispose();
    if (value == null || !mounted) return;
    setState(() => _custom = value.trim().isEmpty ? null : value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<AppProvider>().isAfterDark;
    final list = _scenarios[_mode]!;
    final hasBuiltIn = list.isNotEmpty;
    final primary = dark ? AppColors.darkAccent : AppColors.normalPrimary;
    final muted = dark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final foreground = dark ? AppColors.darkText : AppColors.normalText;
    final surface = dark ? AppColors.darkCard : AppColors.normalCard;
    final shownScenario = _custom ??
        (hasBuiltIn
            ? '${HtmlLegacyContent.roleplayContext[_index % HtmlLegacyContent.roleplayContext.length]}\n\n${list[_index % list.length]}'
            : 'Belum ada skenario bawaan pada kategori ini. Tambahkan skenario custom yang nyaman untuk kalian.');

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Roleplay')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Coba cerita dari sudut pandang yang berbeda.', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih peran dan skenario bersama. Mode Eksplisit hanya untuk orang dewasa dan wajib disetujui kedua pemain.',
                      style: TextStyle(color: muted, height: 1.5),
                    ),
                    const SizedBox(height: 18),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'Biasa', icon: Icon(Icons.forum_outlined), label: Text('Biasa')),
                        ButtonSegment(value: 'Eksplisit', icon: Icon(Icons.local_fire_department_outlined), label: Text('Eksplisit')),
                      ],
                      selected: {_mode},
                      onSelectionChanged: (value) => setState(() {
                        _mode = value.first;
                        _index = 0;
                        _custom = null;
                        _consented = false;
                      }),
                    ),
                    if (_mode == 'Eksplisit') ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: dark ? AppColors.darkBorder : AppColors.normalBorder),
                        ),
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _consented,
                          activeColor: primary,
                          onChanged: (value) => setState(() => _consented = value ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text('Kami berdua orang dewasa dan menyetujui batas permainan ini.'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      constraints: const BoxConstraints(minHeight: 280),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: dark
                              ? const [Color(0xFF442038), Color(0xFF211326), Color(0xFF17101E)]
                              : const [Color(0xFFFFDDE5), Color(0xFFFFEEF0), Color(0xFFF9E4D8)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: primary.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.theater_comedy_rounded, color: primary, size: 21),
                              const SizedBox(width: 8),
                              Text('SKENARIO ${_index + 1}', style: TextStyle(color: primary, fontSize: 11, letterSpacing: 1.6, fontWeight: FontWeight.w800)),
                              const Spacer(),
                              Icon(Icons.auto_awesome_rounded, color: dark ? AppColors.gold : AppColors.normalSecondary),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Text(shownScenario, style: TextStyle(fontSize: 20, height: 1.5, fontWeight: FontWeight.w600, color: foreground)),
                          const SizedBox(height: 20),
                          Text(
                            _custom != null ? 'Skenario custom' : hasBuiltIn ? 'Skenario bawaan IGNITE' : 'Konten custom',
                            style: TextStyle(color: muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: hasBuiltIn && (_mode != 'Eksplisit' || _consented)
                          ? () => setState(() { _index = _random.nextInt(list.length); _custom = null; })
                          : null,
                      icon: const Icon(Icons.shuffle_rounded),
                      label: const Text('Skenario berikutnya'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _mode != 'Eksplisit' || _consented ? _writeCustomScenario : null,
                      icon: const Icon(Icons.edit_note_rounded),
                      label: const Text('Tulis skenario sendiri'),
                    ),
                    if (_custom != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => setState(() => _custom = null),
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: const Text('Kembali ke skenario bawaan'),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      _mode == 'Eksplisit'
                          ? 'Kategori eksplisit bawaan HTML dimulai kosong. Tambahkan konten sendiri; jangan gunakan skenario yang tidak disepakati bersama.'
                          : 'Gunakan skenario sebagai pemantik cerita. Kalian boleh berhenti atau mengganti peran kapan saja.',
                      style: TextStyle(color: muted, fontSize: 12, height: 1.5),
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
