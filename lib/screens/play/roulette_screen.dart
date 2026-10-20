import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';

class IgniteRouletteScreen extends StatefulWidget {
  const IgniteRouletteScreen({super.key});

  @override
  State<IgniteRouletteScreen> createState() => _IgniteRouletteScreenState();
}

class _IgniteRouletteScreenState extends State<IgniteRouletteScreen> {
  final Random _random = Random();
  int _chanceLevel = 1;
  int _turn = 0;
  int _hits1 = 0;
  int _hits2 = 0;
  int _total = 0;
  String? _result;
  bool _rulesAccepted = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<AppProvider>().isAfterDark;
    final primary = dark ? AppColors.darkAccent : AppColors.normalPrimary;
    final muted = dark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final surface = dark ? AppColors.darkCard : AppColors.normalCard;
    final foreground = dark ? AppColors.darkText : AppColors.normalText;
    final chancePercent = _chanceLevel == 1 ? 17 : _chanceLevel == 2 ? 33 : 50;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Russian Roulette Cinta')),
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
                    Text('Keberanian kecil, kejutan besar.', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Permainan peluang virtual—bukan senjata sungguhan. Hasil hanya memunculkan tantangan percakapan ringan, dan siapa pun boleh melewatinya.',
                      style: TextStyle(color: muted, height: 1.5),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: dark ? AppColors.darkBorder : AppColors.normalBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.favorite_rounded, color: primary),
                              const SizedBox(width: 9),
                              Text('Sebelum mulai', style: Theme.of(context).textTheme.titleLarge),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Sepakati aturan bersama. Tantangan tetap ringan, aman, dan dapat ditolak tanpa konsekuensi.', style: TextStyle(color: muted, height: 1.45)),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            value: _rulesAccepted,
                            onChanged: (value) => setState(() => _rulesAccepted = value ?? false),
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Kami memahami aturan dan setuju bermain.'),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('Intensitas peluang', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text('Tingkat $_chanceLevel dari 3 · peluang kejutan $chancePercent%', style: TextStyle(color: muted, fontSize: 12)),
                    Slider(
                      value: _chanceLevel.toDouble(),
                      min: 1,
                      max: 3,
                      divisions: 2,
                      label: 'Tingkat $_chanceLevel',
                      onChanged: (value) => setState(() => _chanceLevel = value.round()),
                      activeColor: primary,
                    ),
                    const SizedBox(height: 8),
                    Container(
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
                        boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 10))],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primary.withValues(alpha: 0.12),
                              border: Border.all(color: primary.withValues(alpha: 0.35)),
                            ),
                            child: Icon(Icons.casino_rounded, size: 38, color: primary),
                          ),
                          const SizedBox(height: 16),
                          Text('Giliran Pemain ${_turn + 1}', style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(child: _score('Pemain 1', _hits1, primary, foreground, muted)),
                              const SizedBox(width: 10),
                              Expanded(child: _score('Pemain 2', _hits2, primary, foreground, muted)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('Putaran ke-$_total', style: TextStyle(color: muted, fontSize: 12)),
                          if (_result != null) ...[
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: surface.withValues(alpha: 0.82), borderRadius: BorderRadius.circular(18)),
                              child: Text(_result!, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.45, fontWeight: FontWeight.w600, color: foreground)),
                            ),
                          ],
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: !_rulesAccepted ? null : () => setState(() {
                                final hit = _random.nextInt(6) < _chanceLevel;
                                _total++;
                                _result = hit
                                    ? '✨ Kejutan! Pemain ${_turn + 1} mendapat tantangan ringan. Pilih tantangan yang nyaman atau lewati.'
                                    : '🌙 Aman untuk ronde ini. Pemain ${_turn + 1} lolos—giliran berganti.';
                                if (hit) {
                                  if (_turn == 0) {
                                    _hits1++;
                                  } else {
                                    _hits2++;
                                  }
                                }
                                _turn = 1 - _turn;
                              }),
                              icon: const Icon(Icons.auto_awesome_rounded),
                              label: const Text('Buka kejutan'),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => setState(() {
                              _turn = 0;
                              _hits1 = 0;
                              _hits2 = 0;
                              _total = 0;
                              _result = null;
                            }),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Mulai ulang'),
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

  Widget _score(String label, int score, Color primary, Color foreground, Color muted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: muted)),
          const SizedBox(height: 5),
          Text('$score', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: foreground)),
          Text('kejutan', style: TextStyle(fontSize: 10, color: muted)),
        ],
      ),
    );
  }
}
