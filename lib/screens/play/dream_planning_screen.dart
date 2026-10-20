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
  static const Map<String, List<String>> _questions = {
    'Perjalanan': [
      'Tempat yang ingin kita kunjungi bersama?',
      'Pengalaman apa yang ingin kita coba di sana?',
    ],
    'Rumah & Rutinitas': [
      'Seperti apa ruang nyaman impian kita?',
      'Tradisi kecil apa yang ingin kita bangun?',
    ],
    'Tujuan Bersama': [
      'Target apa yang ingin kita capai dalam 12 bulan?',
      'Langkah kecil pertama yang bisa dilakukan minggu ini?',
    ],
    'Hubungan': [
      'Apa yang ingin kita lakukan lebih sering?',
      'Bagaimana kita ingin saling mendukung saat sibuk?',
    ],
  };

  final Map<String, TextEditingController> _answers = {};
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    for (final group in _questions.values) {
      for (final question in group) {
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
          final controller = _answers[entry.key];
          if (controller != null && entry.value is String) {
            controller.text = entry.value as String;
          }
        }
      });
    } catch (_) {
      // Keep the form usable if saved data is malformed.
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
    final values = _answers.map(
      (key, controller) => MapEntry(key, controller.text.trim()),
    );
    await prefs.setString(
      'ignite_dream_planning_answers',
      jsonEncode(values),
    );
    if (mounted) setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<AppProvider>().isAfterDark;
    final couple = context.watch<CoupleProvider>().profile;
    final textColor = dark ? AppColors.darkText : AppColors.normalText;
    final mutedColor =
        dark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final primaryColor =
        dark ? AppColors.darkPrimary : AppColors.normalPrimary;

    final children = <Widget>[
      Text(
        'Rancang masa depan bersama ${couple.partner1} dan ${couple.partner2}. '
        'Jawaban tersimpan lokal di perangkat.',
        style: TextStyle(color: mutedColor, height: 1.5),
      ),
      const SizedBox(height: 16),
    ];

    for (final group in _questions.entries) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            group.key,
            style: TextStyle(
              color: textColor,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      for (final question in group.value) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: _answers[question],
              maxLines: 2,
              decoration: InputDecoration(
                labelText: question,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: dark ? AppColors.darkCard : AppColors.normalCard,
              ),
            ),
          ),
        );
      }
      children.add(const SizedBox(height: 10));
    }

    children.add(
      FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: primaryColor),
        onPressed: _save,
        icon: const Icon(Icons.save),
        label: const Text('Simpan impian bersama'),
      ),
    );

    if (_saved) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            'Tersimpan ✓',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Dream Planning')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: children,
      ),
    );
  }
}
