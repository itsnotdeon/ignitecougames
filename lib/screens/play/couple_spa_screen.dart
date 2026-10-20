import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';

class CoupleSpaScreen extends StatefulWidget {
  const CoupleSpaScreen({super.key});

  @override
  State<CoupleSpaScreen> createState() => _CoupleSpaScreenState();
}

class _CoupleSpaScreenState extends State<CoupleSpaScreen> {
  static const _steps = <({String title, String instruction, int seconds})>[
    (title: 'Siapkan suasana', instruction: 'Redupkan lampu jika nyaman, siapkan air minum, dan tanyakan apakah pasangan ingin melanjutkan.', seconds: 60),
    (title: 'Relaksasi bahu', instruction: 'Tanyakan area dan tekanan yang nyaman. Pijat bahu dengan lembut; hentikan jika terasa tidak nyaman.', seconds: 120),
    (title: 'Jeda dan apresiasi', instruction: 'Ambil napas perlahan, lalu sampaikan satu hal yang kamu hargai dari pasangan.', seconds: 60),
  ];
  int _step = 0;
  int _remaining = 60;
  Timer? _timer;
  bool _running = false;
  bool _complete = false;

  @override
  void initState() {
    super.initState();
    _remaining = _steps.first.seconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    if (_remaining <= 0) return;
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remaining <= 1) {
        timer.cancel();
        setState(() { _remaining = 0; _running = false; });
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _nextStep() {
    _timer?.cancel();
    setState(() {
      _running = false;
      if (_step >= _steps.length - 1) {
        _complete = true;
      } else {
        _step++;
        _remaining = _steps[_step].seconds;
      }
    });
  }

  void _restart() {
    _timer?.cancel();
    setState(() { _step = 0; _remaining = _steps.first.seconds; _running = false; _complete = false; });
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<AppProvider>().isAfterDark;
    final primary = dark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final text = dark ? AppColors.darkText : AppColors.normalText;
    final muted = dark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final card = dark ? AppColors.darkCard : AppColors.normalCard;
    final step = _steps[_step];
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Couple Spa Night')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Sesi relaksasi terpandu untuk dua orang. Selalu tanyakan persetujuan sebelum menyentuh dan berhenti kapan pun salah satu tidak nyaman.', style: TextStyle(color: muted, height: 1.5)),
        const SizedBox(height: 18),
        if (_complete) ...[
          Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(24)), child: Column(children: [const Text('🌿', style: TextStyle(fontSize: 54)), const SizedBox(height: 12), Text('Sesi selesai', style: TextStyle(color: text, fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text('Semoga kalian merasa lebih tenang dan dekat.', textAlign: TextAlign.center, style: TextStyle(color: muted))])),
          const SizedBox(height: 14), FilledButton.icon(onPressed: _restart, icon: const Icon(Icons.refresh), label: const Text('Ulangi sesi')),
        ] else ...[
          LinearProgressIndicator(value: (_step + 1) / _steps.length, color: primary, backgroundColor: primary.withValues(alpha: .15)),
          const SizedBox(height: 18),
          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(gradient: LinearGradient(colors: dark ? const [Color(0xFF321528), Color(0xFF21132F)] : const [Color(0xFFFFE4EA), Color(0xFFFFF7E9)]), borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('LANGKAH ${_step + 1} / ${_steps.length}', style: TextStyle(color: primary, fontWeight: FontWeight.bold, letterSpacing: 1.3)), const SizedBox(height: 14), Text(step.title, style: TextStyle(color: text, fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Text(step.instruction, style: TextStyle(color: text, height: 1.5)), const SizedBox(height: 24), Center(child: Text('${(_remaining ~/ 60).toString().padLeft(2, '0')}:${(_remaining % 60).toString().padLeft(2, '0')}', style: TextStyle(color: text, fontSize: 40, fontWeight: FontWeight.w800))), const SizedBox(height: 12), Center(child: FilledButton.icon(onPressed: _remaining == 0 ? null : _toggleTimer, icon: Icon(_running ? Icons.pause : Icons.play_arrow), label: Text(_running ? 'Jeda timer' : 'Mulai timer')))])),
          const SizedBox(height: 12), FilledButton.icon(onPressed: _nextStep, icon: const Icon(Icons.arrow_forward), label: Text(_step == _steps.length - 1 ? 'Selesaikan sesi' : 'Langkah berikutnya')),
          TextButton(onPressed: _restart, child: const Text('Reset sesi')),
        ],
      ]),
    );
  }
}