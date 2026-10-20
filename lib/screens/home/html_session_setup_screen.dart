import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../providers/couple_provider.dart';
import '../../theme/app_colors.dart';

class HtmlSessionSetupScreen extends StatefulWidget {
  const HtmlSessionSetupScreen({super.key});

  @override
  State<HtmlSessionSetupScreen> createState() => _HtmlSessionSetupScreenState();
}

class _HtmlSessionSetupScreenState extends State<HtmlSessionSetupScreen> {
  late final TextEditingController _p1;
  late final TextEditingController _p2;
  String _ritual = 'Gunting Batu Kertas';
  String? _result;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    final profile = context.read<CoupleProvider>().profile;
    _p1 = TextEditingController(text: profile.partner1);
    _p2 = TextEditingController(text: profile.partner2);
  }

  @override
  void dispose() {
    _p1.dispose();
    _p2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<AppProvider>().isAfterDark;
    final primary = dark ? AppColors.darkPrimary : AppColors.normalPrimary;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Mulai Sesi IGNITE')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Sumber HTML IGNITE: isi nama pemain, pilih ritual pemanasan, atau langsung lewati ritual.', style: TextStyle(color: dark ? AppColors.darkTextMuted : AppColors.normalTextMuted, height: 1.5)),
        const SizedBox(height: 18),
        TextField(controller: _p1, maxLength: 24, decoration: const InputDecoration(labelText: 'Nama Pemain 1', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: _p2, maxLength: 24, decoration: const InputDecoration(labelText: 'Nama Pemain 2', border: OutlineInputBorder())),
        const SizedBox(height: 18),
        Text('Ritual pemanasan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        RadioListTile<String>(value: 'Gunting Batu Kertas', groupValue: _ritual, onChanged: (v) => setState(() { _ritual = v!; _result = null; }), title: const Text('✊ Gunting Batu Kertas'), subtitle: const Text('Tentukan siapa yang mulai lebih dulu.')),
        RadioListTile<String>(value: 'Tebak Warna Kartu', groupValue: _ritual, onChanged: (v) => setState(() { _ritual = v!; _result = null; }), title: const Text('🃏 Tebak Warna Kartu'), subtitle: const Text('Pemanasan singkat dengan hasil acak.')),
        if (_result != null) Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: dark ? AppColors.darkCard : AppColors.normalCard, borderRadius: BorderRadius.circular(14)), child: Text(_result!, style: const TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: _runRitual, icon: const Icon(Icons.casino), label: const Text('Jalankan ritual')),
        const SizedBox(height: 8),
        OutlinedButton.icon(onPressed: () => _finish(skipRitual: true), icon: const Icon(Icons.skip_next), label: const Text('Lewati ritual & pilih game')),
        const SizedBox(height: 8),
        FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: primary), onPressed: () => _finish(skipRitual: false), icon: const Icon(Icons.play_arrow), label: const Text('Simpan nama & mulai bermain')),
      ]),
    );
  }

  void _runRitual() {
    final first = _p1.text.trim().isEmpty ? 'Pemain 1' : _p1.text.trim();
    final second = _p2.text.trim().isEmpty ? 'Pemain 2' : _p2.text.trim();
    if (_ritual == 'Tebak Warna Kartu') {
      final color = _random.nextBool() ? 'merah' : 'hitam';
      setState(() => _result = 'Kartu virtual terpilih: $color. Gunakan sebagai pemanasan ringan sebelum memilih game.');
    } else {
      const options = ['Batu', 'Kertas', 'Gunting'];
      final a = options[_random.nextInt(3)];
      final b = options[_random.nextInt(3)];
      final winner = a == b ? 'Seri!' : ((a == 'Batu' && b == 'Gunting') || (a == 'Kertas' && b == 'Batu') || (a == 'Gunting' && b == 'Kertas')) ? '$first menang dan mulai dulu.' : '$second menang dan mulai dulu.';
      setState(() => _result = '$first: $a · $second: $b. $winner');
    }
  }

  Future<void> _finish({required bool skipRitual}) async {
    await context.read<CoupleProvider>().updateProfile(
      partner1: _p1.text.trim().isEmpty ? 'Pemain 1' : _p1.text.trim(),
      partner2: _p2.text.trim().isEmpty ? 'Pemain 2' : _p2.text.trim(),
    );
    if (!mounted) return;
    context.read<AppProvider>().setTabIndex(1);
    Navigator.pop(context);
    if (skipRitual && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ritual dilewati. Pilih permainan yang kalian inginkan.')));
    }
  }
}