import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/html_legacy_content.dart';
import '../../providers/app_provider.dart';
import '../../providers/couple_provider.dart';
import '../../theme/app_colors.dart';

class HtmlSnakeLadderScreen extends StatefulWidget {
  const HtmlSnakeLadderScreen({super.key});

  @override
  State<HtmlSnakeLadderScreen> createState() => _HtmlSnakeLadderScreenState();
}

class _HtmlSnakeLadderScreenState extends State<HtmlSnakeLadderScreen> {
  final Random _random = Random();
  final Map<int, int> _ladders = const {3: 22, 8: 30, 20: 41, 28: 55, 50: 67, 71: 91, 80: 99};
  final Map<int, int> _snakes = const {17: 7, 27: 5, 54: 34, 62: 19, 64: 60, 87: 24, 93: 73, 95: 75, 99: 78};
  final Set<int> _special = const {5, 12, 18, 26, 33, 45, 57, 68, 76, 84, 90}.toSet();
  int _p1 = 0;
  int _p2 = 0;
  int _turn = 1;
  int? _lastRoll;
  String? _message;
  String? _prompt;
  bool _explicit = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<AppProvider>().isAfterDark;
    final couple = context.watch<CoupleProvider>().profile;
    final primary = dark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final card = dark ? AppColors.darkCard : AppColors.normalCard;
    final text = dark ? AppColors.darkText : AppColors.normalText;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Ular Tangga Cinta')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
          Text('Pemain bergiliran melempar dadu, bergerak di papan 1–100, dan menyelesaikan topik pada petak spesial. Tangga naik, ular turun.', style: TextStyle(color: dark ? AppColors.darkTextMuted : AppColors.normalTextMuted, height: 1.45)),
          const SizedBox(height: 16),
          Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: SegmentedButton<bool>(segments: const [ButtonSegment(value: false, label: Text('🃏 Biasa')), ButtonSegment(value: true, label: Text('🔥 Eksplisit'))], selected: {_explicit}, onSelectionChanged: (v) => setState(() { _explicit = v.first; _prompt = null; _message = null; }))),
          const SizedBox(height: 14),
          Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: dark ? const [Color(0xFF302035), Color(0xFF1A101F)] : const [Color(0xFFFFE5EB), Color(0xFFFFF5EC)]), borderRadius: BorderRadius.circular(22), border: Border.all(color: dark ? AppColors.darkBorder : AppColors.normalBorder)), child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10, crossAxisSpacing: 3, mainAxisSpacing: 3),
            itemCount: 100,
            itemBuilder: (context, index) {
              final number = 100 - index;
              final p1 = _p1 == number && _p1 > 0;
              final p2 = _p2 == number && _p2 > 0;
              final special = _special.contains(number);
              final ladder = _ladders.containsKey(number);
              final snake = _snakes.containsKey(number);
              return Container(
                decoration: BoxDecoration(color: p1 ? primary : p2 ? (dark ? AppColors.darkSecondary : AppColors.normalSecondary) : ladder ? (dark ? const Color(0xFF25483C) : const Color(0xFFD8F3DC)) : snake ? (dark ? const Color(0xFF592C3B) : const Color(0xFFFFD6DF)) : special ? (dark ? AppColors.darkHighlight : AppColors.normalHighlight) : ((number + (number ~/ 10)).isEven ? (dark ? const Color(0xFF2B1B36) : const Color(0xFFFFFDFD)) : (dark ? const Color(0xFF241722) : const Color(0xFFFFF0F2))), borderRadius: BorderRadius.circular(5), border: Border.all(color: (dark ? AppColors.darkBorder : AppColors.normalBorder).withValues(alpha: 0.55))),
                alignment: Alignment.center,
                child: FittedBox(child: Text('${p1 ? '●' : ''}${p2 ? '♥' : ''}${ladder ? '↗' : snake ? '↘' : ''}${number}', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: (p1 || p2) ? Colors.white : text))),
              );
            },
          ))),
          const SizedBox(height: 14),
          Row(children: [Expanded(child: _playerCard(couple.partner1, _p1, _turn == 1, primary, card, text)), const SizedBox(width: 8), Expanded(child: _playerCard(couple.partner2, _p2, _turn == 2, dark ? AppColors.darkSecondary : AppColors.normalSecondary, card, text))]),
          const SizedBox(height: 12),
          if (_message != null) Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14)), child: Text(_message!, style: TextStyle(color: text, fontWeight: FontWeight.w600))),
          if (_prompt != null) Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: LinearGradient(colors: dark ? const [Color(0xFF35142B), Color(0xFF1A1026)] : const [Color(0xFFFFE4EA), Color(0xFFFFF7E9)]), borderRadius: BorderRadius.circular(16)), child: Text(_prompt!, style: TextStyle(color: text, fontSize: 16, height: 1.4))),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: (_p1 >= 100 || _p2 >= 100) ? null : _roll, icon: const Icon(Icons.casino), label: Text(_lastRoll == null ? 'Lempar dadu — ${_turn == 1 ? couple.partner1 : couple.partner2}' : 'Lempar lagi — ${_turn == 1 ? couple.partner1 : couple.partner2}')),
          OutlinedButton.icon(onPressed: () => setState(() { _p1 = 0; _p2 = 0; _turn = 1; _lastRoll = null; _message = null; _prompt = null; }), icon: const Icon(Icons.refresh), label: const Text('Mulai ulang')),
          ],
        ),
      ),
    );
  }

  Widget _playerCard(String name, int position, bool active, Color primary, Color card, Color text) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: active ? primary.withOpacity(.14) : card, borderRadius: BorderRadius.circular(14), border: Border.all(color: active ? primary : Colors.transparent)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text('Petak $position', style: TextStyle(color: text))]));

  void _roll() {
    final roll = _random.nextInt(6) + 1;
    final current = _turn == 1 ? _p1 : _p2;
    var next = current + roll;
    if (next > 100) next = current;
    var message = 'Dadu: $roll. Pemain $_turn bergerak ke petak $next.';
    if (_ladders.containsKey(next)) { message = 'Naik tangga! Petak $next menuju ${_ladders[next]}.'; next = _ladders[next]!; }
    if (_snakes.containsKey(next)) { message = 'Kena ular! Petak $next turun ke ${_snakes[next]}.'; next = _snakes[next]!; }
    String? prompt;
    if (_special.contains(next)) {
      if (_explicit) {
        prompt = 'Petak spesial: sepakati topik custom yang nyaman untuk kalian. Kalian boleh melewati petak ini.';
      } else {
        prompt = HtmlLegacyContent.cards[_random.nextInt(HtmlLegacyContent.cards.length)];
      }
      message = '$message Petak spesial terbuka.';
    }
    setState(() {
      if (_turn == 1) { _p1 = next; } else { _p2 = next; }
      _lastRoll = roll;
      _message = next >= 100 ? 'Pemain $_turn mencapai petak 100 dan menang!' : message;
      _prompt = prompt;
      if (next < 100) _turn = _turn == 1 ? 2 : 1;
    });
  }
}