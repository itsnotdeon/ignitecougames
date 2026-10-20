import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/app_provider.dart';
import '../../providers/couple_provider.dart';
import '../../theme/app_colors.dart';

class DreamPlanningScreen extends StatefulWidget {
  const DreamPlanningScreen({super.key});

  @override
  State<DreamPlanningScreen> createState() => _DreamPlanningScreenState();
}

class _DreamPlanningScreenState extends State<DreamPlanningScreen> {
  static const _questions = <String, List<String>>{
    'Perjalanan': ['Tempat yang ingin kita kunjungi bersama?', 'Pengalaman apa yang ingin kita coba di sana?'],
    'Rumah & Rutinitas': ['Seperti apa ruang nyaman impian kita?', 'Tradisi kecil apa yang ingin kita bangun?'],
    'Tujuan Bersama': ['Target apa yang ingin kita capai dalam 12 bulan?', 'Langkah kecil pertama yang bisa dilakukan minggu ini?'],
    'Hubungan': ['Apa yang ingin kita lakukan lebih sering?', 'Bagaimana kita ingin saling mendukung saat sibuk?'],
  };
  final Map<String, TextEditingController> _answers = {};
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    for (final group in _questions.entries) {
      for (final question in group.value) {
        _answers[question] = TextEditingController();
      }
    }
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('ignite_dream_planning_answers');
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        for (final entry in decoded.entries) {
          if (_answers.containsKey(entry.key) && entry.value is String) _answers[entry.key]!.text = entry.value as String;
        }
      });
    } catch (_) {
      // Ignore corrupt local data and keep a clean form.
    }
  }

  @override
  void dispose() {
    for (final controller in _answers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ignite_dream_planning_answers', jsonEncode(_answers.map((key, value) => MapEntry(key, value.text.trim()))));
    if (mounted) setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<AppProvider>().isAfterDark;
    final couple = context.watch<CoupleProvider>().profile;
    final text = dark ? AppColors.darkText : AppColors.normalText;
    final muted = dark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final primary = dark ? AppColors.darkPrimary : AppColors.normalPrimary;
    return Scaffold(backgroundColor: Colors.transparent, appBar: AppBar(title: const Text('Dream Planning')), body: ListView(padding: const EdgeInsets.all(20), children: [
      Text('Rancang masa depan bersama ${couple.partner1} dan ${couple.partner2}. Jawaban tersimpan lokal di perangkat.', style: TextStyle(color: muted, height: 1.5)),
      const SizedBox(height: 16),
      for (final group in _questions.entries) ...[
        Container(margin: const EdgeInsets.only(bottom: 8), child: Text(group.key, style: TextStyle(color: text, fontSize: 19, fontWeight: FontWeight.bold))),
        for (final question in group.value) Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: _answers[question], maxLines: 2, decoration: InputDecoration(labelText: question, alignLabelWithHint: true, border: const OutlineInputBorder(), filled: true, fillColor: dark ? AppColors.darkCard : AppColors.normalCard))),
        const SizedBox(height: 10),
      ],
      FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: primary), onPressed: _save, icon: const Icon(Icons.save), label: const Text('Simpan impian bersama')),
      if (_saved) Padding(padding: const EdgeInsets.only(top: 10), child: Text('Tersimpan ✓', style: TextStyle(color: primary, fontWeight: FontWeight.bold))),
    ])));
  }
}