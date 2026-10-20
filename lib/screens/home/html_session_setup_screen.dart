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
  static const int _minimumRounds = 5;
  static const List<String> _moves = ['Batu', 'Kertas', 'Gunting'];
  static const Map<String, String> _beats = {
    'Batu': 'Gunting',
    'Gunting': 'Kertas',
    'Kertas': 'Batu',
  };

  late final TextEditingController _p1;
  late final TextEditingController _p2;
  final Random _random = Random();

  String _ritual = 'Gunting Batu Kertas';
  bool _started = false;
  bool _finished = false;
  int _roundsPlayed = 0;
  int _turn = 0;
  String _stage = 'p1';
  String? _p1Move;
  String? _p2Move;
  String? _cardColor;
  String? _result;

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

  String get _firstName =>
      _p1.text.trim().isEmpty ? 'Pemain 1' : _p1.text.trim();
  String get _secondName =>
      _p2.text.trim().isEmpty ? 'Pemain 2' : _p2.text.trim();
  String get _currentName => _turn == 0 ? _firstName : _secondName;

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<AppProvider>().isAfterDark;
    final primary = dark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final muted = dark ? AppColors.darkTextMuted : AppColors.normalTextMuted;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Mulai Sesi IGNITE')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Siapkan nama pemain dan pilih ritual pembuka dari versi HTML IGNITE. '
            'Ritual dapat dilewati kapan saja.',
            style: TextStyle(color: muted, height: 1.5),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _p1,
            maxLength: 24,
            enabled: !_started,
            decoration: const InputDecoration(
              labelText: 'Nama Pemain 1',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _p2,
            maxLength: 24,
            enabled: !_started,
            decoration: const InputDecoration(
              labelText: 'Nama Pemain 2',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Ritual pemanasan',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          RadioListTile<String>(
            value: 'Gunting Batu Kertas',
            groupValue: _ritual,
            onChanged: _started
                ? null
                : (value) => setState(() => _ritual = value!),
            title: const Text('✊ Gunting Batu Kertas'),
            subtitle: const Text('Bergiliran memilih secara rahasia.'),
          ),
          RadioListTile<String>(
            value: 'Tebak Warna Kartu',
            groupValue: _ritual,
            onChanged: _started
                ? null
                : (value) => setState(() => _ritual = value!),
            title: const Text('🃏 Tebak Warna Kartu'),
            subtitle: const Text('Tebak merah atau hitam secara bergiliran.'),
          ),
          if (!_started) ...[
            const SizedBox(height: 8),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: primary),
              onPressed: _startRitual,
              icon: const Icon(Icons.casino),
              label: const Text('Mulai ritual'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _finish(skipRitual: true),
              icon: const Icon(Icons.skip_next),
              label: const Text('Lewati ritual & pilih game'),
            ),
          ] else ...[
            const Divider(height: 30),
            _buildRitualPanel(primary, muted),
            const SizedBox(height: 12),
            if (_finished)
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: primary),
                onPressed: () => _finish(skipRitual: false),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Lanjut pilih permainan'),
              )
            else
              OutlinedButton.icon(
                onPressed: () => _finish(skipRitual: true),
                icon: const Icon(Icons.skip_next),
                label: const Text('Lewati ritual & pilih game'),
              ),
            TextButton(
              onPressed: _resetRitual,
              child: const Text('Ulangi ritual dari awal'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRitualPanel(Color primary, Color muted) {
    final displayedRound = _roundsPlayed >= _minimumRounds ? _minimumRounds : _roundsPlayed + 1;
    final roundText = 'Ronde $displayedRound dari $_minimumRounds';
    if (_finished) {
      return Column(
        children: [
          const Icon(Icons.favorite_rounded, size: 54),
          const SizedBox(height: 8),
          Text(
            'Selamat datang, $_firstName & $_secondName! ❤',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text('Ritual pemanasan selesai setelah $_roundsPlayed ronde.',
              style: TextStyle(color: muted)),
        ],
      );
    }

    if (_ritual == 'Tebak Warna Kartu') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(roundText, style: TextStyle(color: muted)),
          const SizedBox(height: 6),
          Text(
            'Giliran: $_currentName',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 130,
              height: 160,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: primary, width: 2),
              ),
              child: Text(
                _cardColor == null ? '🂠' : (_cardColor == 'Merah' ? '♥' : '♠'),
                style: TextStyle(
                  fontSize: 68,
                  color: _cardColor == 'Merah' ? Colors.red : Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_result == null) ...[
            const Text('Tebak warna kartu yang tertutup:'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _guessColor('Merah'),
                    child: const Text('♥ Merah'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _guessColor('Hitam'),
                    child: const Text('♠ Hitam'),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(_result!, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            if (_roundsPlayed >= _minimumRounds)
              FilledButton(
                onPressed: () => setState(() => _finished = true),
                child: const Text('Semua sudah siap'),
              )
            else
              FilledButton(
                onPressed: _nextColorRound,
                child: const Text('Ronde berikutnya ➜'),
              ),
          ],
          if (_roundsPlayed < _minimumRounds && _result != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Minimal $_minimumRounds ronde sebelum lanjut.',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(roundText, style: TextStyle(color: muted)),
        const SizedBox(height: 6),
        Text(
          _stage == 'p1'
              ? 'Giliran: $_firstName — pilih diam-diam, lalu oper perangkat.'
              : _stage == 'p2'
                  ? 'Giliran: $_secondName — pilih diam-diam.'
                  : 'Hasil ronde ini:',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        if (_stage == 'p1' || _stage == 'p2')
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _moves
                .map(
                  (move) => ActionChip(
                    label: Text(move),
                    onPressed: () => _pickMove(move),
                  ),
                )
                .toList(),
          )
        else ...[
          Text(
            '$_firstName: ${_moveEmoji(_p1Move)}   vs   $_secondName: ${_moveEmoji(_p2Move)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_result ?? '', textAlign: TextAlign.center),
          const SizedBox(height: 10),
          if (_roundsPlayed >= _minimumRounds)
            FilledButton(
              onPressed: () => setState(() => _finished = true),
              child: const Text('Semua sudah siap'),
            )
          else
            FilledButton(
              onPressed: _nextRpsRound,
              child: const Text('Ronde berikutnya ➜'),
            ),
        ],
        if (_stage == 'result' && _roundsPlayed < _minimumRounds)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Minimal $_minimumRounds ronde sebelum lanjut.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 12),
            ),
          ),
      ],
    );
  }

  String _moveEmoji(String? move) => switch (move) {
        'Batu' => '✊',
        'Kertas' => '✋',
        'Gunting' => '✌️',
        _ => '❔',
      };

  void _startRitual() {
    setState(() {
      _started = true;
      _finished = false;
      _roundsPlayed = 0;
      _turn = 0;
      _stage = 'p1';
      _p1Move = null;
      _p2Move = null;
      _cardColor = null;
      _result = null;
    });
  }

  void _resetRitual() {
    setState(() {
      _started = false;
      _finished = false;
      _roundsPlayed = 0;
      _turn = 0;
      _stage = 'p1';
      _p1Move = null;
      _p2Move = null;
      _cardColor = null;
      _result = null;
    });
  }

  void _guessColor(String guess) {
    final actual = _random.nextBool() ? 'Merah' : 'Hitam';
    setState(() {
      _cardColor = actual;
      _result = guess == actual
          ? 'Benar! Kartunya berwarna $actual.'
          : 'Kurang tepat — kartunya berwarna $actual. Giliran pindah ke pemain berikutnya.';
      _roundsPlayed += 1;
    });
  }

  void _nextColorRound() {
    setState(() {
      _turn = _turn == 0 ? 1 : 0;
      _cardColor = null;
      _result = null;
    });
  }

  void _pickMove(String move) {
    setState(() {
      if (_stage == 'p1') {
        _p1Move = move;
        _stage = 'p2';
      } else if (_stage == 'p2') {
        _p2Move = move;
        _stage = 'result';
        _roundsPlayed += 1;
        if (_p1Move == _p2Move) {
          _result = 'Seri! Kalian sama-sama memilih $move.';
        } else if (_beats[_p1Move] == _p2Move) {
          _result = '$_firstName menang — $_firstName boleh memilih tantangan ringan untuk $_secondName.';
        } else {
          _result = '$_secondName menang — $_secondName boleh memilih tantangan ringan untuk $_firstName.';
        }
      }
    });
  }

  void _nextRpsRound() {
    setState(() {
      _stage = 'p1';
      _p1Move = null;
      _p2Move = null;
      _result = null;
    });
  }

  Future<void> _finish({required bool skipRitual}) async {
    await context.read<CoupleProvider>().updateProfile(
          partner1: _firstName,
          partner2: _secondName,
        );
    if (!mounted) return;
    context.read<AppProvider>().setTabIndex(1);
    Navigator.pop(context);
    if (skipRitual) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ritual dilewati. Pilih permainan yang kalian inginkan.'),
        ),
      );
    }
  }
}
