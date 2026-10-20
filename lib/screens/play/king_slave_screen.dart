import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/html_legacy_content.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';

class KingSlaveScreen extends StatefulWidget {
  const KingSlaveScreen({super.key});

  @override
  State<KingSlaveScreen> createState() => _KingSlaveScreenState();
}

class _KingSlaveScreenState extends State<KingSlaveScreen> {
  final Random _random = Random();
  int _round = 1;
  int _king = 0;
  bool _consented = false;
  String? _command;

  final List<String> _commands = [
    'Pilih satu lagu yang menggambarkan hubungan kalian dan jelaskan alasannya.',
    'Berikan tiga apresiasi tulus kepada pasangan.',
    'Ceritakan satu kenangan favorit kalian bersama.',
    'Pilih aktivitas kecil yang ingin kalian lakukan bersama minggu ini.',
    'Tanyakan satu hal yang ingin kalian pahami lebih baik tentang pasangan.',
  ];
  final List<Map<String, String>> _powers = HtmlLegacyContent.powerCards;

  String _drawPowerCard() {
    final power = _powers[_random.nextInt(_powers.length)];
    return '${power['name']}: ${power['desc']} Gunakan hanya jika kedua pemain setuju.';
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<AppProvider>().isAfterDark;
    final primary = dark ? AppColors.darkAccent : AppColors.normalPrimary;
    final muted = dark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final foreground = dark ? AppColors.darkText : AppColors.normalText;
    final surface = dark ? AppColors.darkCard : AppColors.normalCard;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('King & Slave')),
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
                    Text('Peran, kepercayaan, dan kesepakatan.', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Sepakati batas sebelum mulai. Peran hanya permainan; setiap perintah boleh ditolak dan persetujuan dapat ditarik kapan saja.',
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
                              Text('Ritual kesepakatan', style: Theme.of(context).textTheme.titleLarge),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Pastikan semua perintah nyaman, aman, dan dapat dilewati tanpa konsekuensi.', style: TextStyle(color: muted, height: 1.45)),
                          const SizedBox(height: 6),
                          CheckboxListTile(
                            value: _consented,
                            onChanged: (value) => setState(() => _consented = value ?? false),
                            contentPadding: EdgeInsets.zero,
                            activeColor: primary,
                            title: const Text('Kami berdua setuju dan siap bermain dengan batas yang disepakati.'),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        border: Border.all(color: primary.withValues(alpha: 0.26)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.workspace_premium_rounded, size: 38, color: dark ? AppColors.gold : AppColors.normalSecondary),
                          const SizedBox(height: 12),
                          Text('RONDE KE-$_round', style: TextStyle(fontSize: 11, letterSpacing: 1.8, fontWeight: FontWeight.w800, color: primary)),
                          const SizedBox(height: 10),
                          Text(
                            _king == 0 ? '👑 Pemain 1 menjadi King / Queen' : '👑 Pemain 2 menjadi King / Queen',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(color: surface.withValues(alpha: 0.82), borderRadius: BorderRadius.circular(18)),
                            child: Text(
                              _command ?? 'Ambil Command Card atau Power Card untuk memulai ronde.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, height: 1.5, color: foreground),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: !_consented ? null : () => setState(() => _command = _commands[_random.nextInt(_commands.length)]),
                              icon: const Icon(Icons.style_rounded),
                              label: const Text('Ambil Command Card'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: !_consented ? null : () => setState(() => _command = _drawPowerCard()),
                              icon: const Icon(Icons.auto_awesome_rounded),
                              label: const Text('Ambil Power Card'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: !_consented ? null : () => setState(() { _round++; _king = 1 - _king; _command = null; }),
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text('Selesaikan ronde & lanjut'),
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
