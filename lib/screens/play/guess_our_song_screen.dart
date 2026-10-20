import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../providers/app_provider.dart';
import '../../providers/bond_provider.dart';
import '../../providers/couple_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/gradient_button.dart';

const _uuid = Uuid();

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

class LyricItem {
  const LyricItem({
    required this.lyric,
    required this.answer,
    required this.hint,
  });

  final String lyric;
  final String answer;
  final String hint;
}

class PlaylistSong {
  PlaylistSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.memory,
    required this.dateAdded,
  });

  factory PlaylistSong.fromJson(Map<String, dynamic> json) => PlaylistSong(
        id: json['id'] as String,
        title: json['title'] as String,
        artist: json['artist'] as String,
        memory: json['memory'] as String,
        dateAdded: json['dateAdded'] as String,
      );

  final String id;
  final String title;
  final String artist;
  final String memory;
  final String dateAdded;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'memory': memory,
        'dateAdded': dateAdded,
      };
}

// ---------------------------------------------------------------------------
// Lyric database
// ---------------------------------------------------------------------------

const List<LyricItem> _lyrics = [
  LyricItem(
    lyric: '"Aku yang lemah tanpamu, aku yang rentan karenamu..."',
    answer: 'Sempurna - Andra & The Backbone',
    hint: '🎸 Rock Indonesia',
  ),
  LyricItem(
    lyric: '"Hingga akhir waktu, ku kan slalu ada..."',
    answer: 'Hingga Akhir Waktu - Sherina',
    hint: '🎵 Pop Indonesia',
  ),
  LyricItem(
    lyric: '"Kamu adalah satu satunya, yang bisa membuatku begini..."',
    answer: 'Kamu - Raisa',
    hint: '💖 Pop Indonesia',
  ),
  LyricItem(
    lyric: '"Never gonna give you up, never gonna let you down..."',
    answer: 'Never Gonna Give You Up - Rick Astley',
    hint: '🎹 Classic Pop',
  ),
  LyricItem(
    lyric: '"Can\'t help falling in love with you..."',
    answer: 'Can\'t Help Falling in Love - Elvis Presley',
    hint: '🎸 Classic',
  ),
  LyricItem(
    lyric: '"All of me, loves all of you, love your curves and all your edges..."',
    answer: 'All of Me - John Legend',
    hint: '🎹 R&B',
  ),
  LyricItem(
    lyric: '"A thousand years I\'ll love you, a thousand more..."',
    answer: 'A Thousand Years - Christina Perri',
    hint: '🌹 Romantic',
  ),
  LyricItem(
    lyric: '"Satu hal yang ku takut, kehilangan dirimu..."',
    answer: 'Takut - Fiersa Besari',
    hint: '💔 Indie Indonesia',
  ),
  LyricItem(
    lyric: '"Terpesona, ku terpesona olehmu..."',
    answer: 'Terpesona - Melly Goeslaw',
    hint: '✨ Pop Indonesia',
  ),
  LyricItem(
    lyric: '"Kau adalah bagian dari hidupku, bagian yang terindah..."',
    answer: 'Bagian dari Hidupku - Flanella',
    hint: '💕 Pop Indonesia',
  ),
];

const String _playlistKey = 'our_playlist';

// ---------------------------------------------------------------------------
// Main Screen
// ---------------------------------------------------------------------------

class GuessOurSongScreen extends StatelessWidget {
  const GuessOurSongScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;
    final bgTop = isAfterDark ? AppColors.darkBgTop : AppColors.normalBgTop;
    final bgBottom = isAfterDark ? AppColors.darkBgBottom : AppColors.normalBgBottom;
    final primary = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [bgTop, bgBottom],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            color: isAfterDark ? AppColors.darkText : AppColors.normalText),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '🎶 Guess Our Song',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isAfterDark ? AppColors.darkText : AppColors.normalText,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tab bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isAfterDark ? AppColors.darkCard : AppColors.normalCard)
                        .withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      gradient: LinearGradient(colors: [primary, primary.withValues(alpha: 0.7)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        (isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: const [
                      Tab(text: '🎵 Tebak Lagu'),
                      Tab(text: 'Our Playlist 🎵'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Expanded(
                  child: TabBarView(
                    children: [
                      _GuessTab(),
                      _PlaylistTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1 – Tebak Lagu
// ---------------------------------------------------------------------------

class _GuessTab extends StatefulWidget {
  const _GuessTab();

  @override
  State<_GuessTab> createState() => _GuessTabState();
}

class _GuessTabState extends State<_GuessTab> {
  final _random = Random();

  late List<int> _remaining;
  late int _currentIndex;

  int _score1 = 0;
  int _score2 = 0;

  bool _revealed = false;
  bool _finished = false;

  final _guess1Controller = TextEditingController();
  final _guess2Controller = TextEditingController();

  // Per-round answer state
  bool? _p1Correct;
  bool? _p2Correct;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _remaining = List.generate(_lyrics.length, (i) => i);
    _remaining.shuffle(_random);
    _currentIndex = _remaining.removeLast();
    _score1 = 0;
    _score2 = 0;
    _revealed = false;
    _finished = false;
    _p1Correct = null;
    _p2Correct = null;
    _guess1Controller.clear();
    _guess2Controller.clear();
  }

  LyricItem get _current => _lyrics[_currentIndex];

  void _reveal() {
    setState(() => _revealed = true);
  }

  void _markAnswer(bool isPartner1, bool correct) {
    setState(() {
      if (isPartner1) {
        _p1Correct = correct;
        if (correct) _score1++;
      } else {
        _p2Correct = correct;
        if (correct) _score2++;
      }
    });
    if (correct) {
      context.read<BondProvider>().addXp(15);
    }
  }

  void _nextLyric() {
    if (_remaining.isEmpty) {
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _currentIndex = _remaining.removeLast();
      _revealed = false;
      _p1Correct = null;
      _p2Correct = null;
      _guess1Controller.clear();
      _guess2Controller.clear();
    });
  }

  bool get _canNext => _p1Correct != null && _p2Correct != null;

  @override
  void dispose() {
    _guess1Controller.dispose();
    _guess2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;
    final profile = context.watch<CoupleProvider>().profile;
    final p1 = profile?.partner1 ?? 'Partner 1';
    final p2 = profile?.partner2 ?? 'Partner 2';
    final e1 = profile?.emoji1 ?? '💑';
    final e2 = profile?.emoji2 ?? '💑';

    if (_finished) {
      return _FinalScore(
        score1: _score1,
        score2: _score2,
        p1: p1,
        p2: p2,
        e1: e1,
        e2: e2,
        isAfterDark: isAfterDark,
        onRestart: () => setState(() => _reset()),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Score bar
          _ScoreBar(
            score1: _score1,
            score2: _score2,
            p1: p1,
            p2: p2,
            e1: e1,
            e2: e2,
            isAfterDark: isAfterDark,
            remaining: _remaining.length + 1,
            total: _lyrics.length,
          ),
          const SizedBox(height: 16),
          // Lyric card
          _LyricCard(item: _current, isAfterDark: isAfterDark),
          const SizedBox(height: 12),
          // Hint
          _HintBadge(hint: _current.hint, isAfterDark: isAfterDark),
          const SizedBox(height: 16),
          // Guess fields
          Row(
            children: [
              Expanded(
                child: _GuessField(
                  controller: _guess1Controller,
                  label: '$e1 $p1',
                  isAfterDark: isAfterDark,
                  enabled: !_revealed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GuessField(
                  controller: _guess2Controller,
                  label: '$e2 $p2',
                  isAfterDark: isAfterDark,
                  enabled: !_revealed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Cek jawaban button
          if (!_revealed)
            GradientButton(
              onPressed: _reveal,
              child: const Text('🔍 Cek Jawaban',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          // Revealed answer + self-report
          if (_revealed) ...[
            _AnswerReveal(answer: _current.answer, isAfterDark: isAfterDark),
            const SizedBox(height: 16),
            _SelfReport(
              p1: p1,
              p2: p2,
              e1: e1,
              e2: e2,
              p1Correct: _p1Correct,
              p2Correct: _p2Correct,
              isAfterDark: isAfterDark,
              onMark: _markAnswer,
            ),
            const SizedBox(height: 16),
            if (_canNext)
              GradientButton(
                onPressed: _nextLyric,
                child: Text(
                  _remaining.isEmpty ? '🏁 Lihat Hasil' : '▶ Lagu Berikutnya',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Score bar widget
// ---------------------------------------------------------------------------

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({
    required this.score1,
    required this.score2,
    required this.p1,
    required this.p2,
    required this.e1,
    required this.e2,
    required this.isAfterDark,
    required this.remaining,
    required this.total,
  });

  final int score1;
  final int score2;
  final String p1;
  final String p2;
  final String e1;
  final String e2;
  final bool isAfterDark;
  final int remaining;
  final int total;

  @override
  Widget build(BuildContext context) {
    final surface = isAfterDark ? AppColors.darkCard : AppColors.normalCard;
    final text = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final muted = isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final primary = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _PlayerScore(emoji: e1, name: p1, score: score1, textColor: text, primary: primary),
          Column(
            children: [
              Text('🎵 $remaining/$total', style: TextStyle(color: muted, fontSize: 12)),
              const SizedBox(height: 2),
              Text('SCORE', style: TextStyle(color: muted, fontSize: 10, letterSpacing: 1)),
            ],
          ),
          _PlayerScore(emoji: e2, name: p2, score: score2, textColor: text, primary: primary),
        ],
      ),
    );
  }
}

class _PlayerScore extends StatelessWidget {
  const _PlayerScore({
    required this.emoji,
    required this.name,
    required this.score,
    required this.textColor,
    required this.primary,
  });

  final String emoji;
  final String name;
  final int score;
  final Color textColor;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        Text(name,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 12)),
        Text('$score pts',
            style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Lyric card
// ---------------------------------------------------------------------------

class _LyricCard extends StatelessWidget {
  const _LyricCard({required this.item, required this.isAfterDark});

  final LyricItem item;
  final bool isAfterDark;

  @override
  Widget build(BuildContext context) {
    final primary = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final surface = isAfterDark ? AppColors.darkCard : AppColors.normalCard;
    final text = isAfterDark ? AppColors.darkText : AppColors.normalText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary.withValues(alpha: 0.15), surface.withValues(alpha: 0.9)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Text('🎶', style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text(
            item.lyric,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: text,
              fontSize: 17,
              fontStyle: FontStyle.italic,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hint badge
// ---------------------------------------------------------------------------

class _HintBadge extends StatelessWidget {
  const _HintBadge({required this.hint, required this.isAfterDark});

  final String hint;
  final bool isAfterDark;

  @override
  Widget build(BuildContext context) {
    final secondary = isAfterDark ? AppColors.darkSecondary : AppColors.normalSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: secondary.withValues(alpha: 0.5)),
      ),
      child: Text(
        'Hint: $hint',
        style: TextStyle(color: secondary, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Guess text field
// ---------------------------------------------------------------------------

class _GuessField extends StatelessWidget {
  const _GuessField({
    required this.controller,
    required this.label,
    required this.isAfterDark,
    required this.enabled,
  });

  final TextEditingController controller;
  final String label;
  final bool isAfterDark;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final surface = isAfterDark ? AppColors.darkSurface : AppColors.normalSurface;
    final border = isAfterDark ? AppColors.darkBorder : AppColors.normalBorder;
    final text = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final muted = isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final primary = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;

    return TextField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(color: text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: muted, fontSize: 12),
        filled: true,
        fillColor: surface.withValues(alpha: 0.8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border.withValues(alpha: 0.5)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Answer reveal
// ---------------------------------------------------------------------------

class _AnswerReveal extends StatelessWidget {
  const _AnswerReveal({required this.answer, required this.isAfterDark});

  final String answer;
  final bool isAfterDark;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.success.withValues(alpha: 0.2), AppColors.gold.withValues(alpha: 0.1)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            const Text('🎉 Jawaban:', style: TextStyle(color: AppColors.success, fontSize: 13)),
            const SizedBox(height: 6),
            Text(
              answer,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Self-report buttons
// ---------------------------------------------------------------------------

class _SelfReport extends StatelessWidget {
  const _SelfReport({
    required this.p1,
    required this.p2,
    required this.e1,
    required this.e2,
    required this.p1Correct,
    required this.p2Correct,
    required this.isAfterDark,
    required this.onMark,
  });

  final String p1;
  final String p2;
  final String e1;
  final String e2;
  final bool? p1Correct;
  final bool? p2Correct;
  final bool isAfterDark;
  final void Function(bool isPartner1, bool correct) onMark;

  @override
  Widget build(BuildContext context) {
    final surface = isAfterDark ? AppColors.darkCard : AppColors.normalCard;
    final text = isAfterDark ? AppColors.darkText : AppColors.normalText;

    return Column(
      children: [
        Text(
          'Siapa yang benar?',
          style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PlayerReportCard(
                emoji: e1,
                name: p1,
                isCorrect: p1Correct,
                surface: surface,
                onCorrect: () => onMark(true, true),
                onWrong: () => onMark(true, false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PlayerReportCard(
                emoji: e2,
                name: p2,
                isCorrect: p2Correct,
                surface: surface,
                onCorrect: () => onMark(false, true),
                onWrong: () => onMark(false, false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlayerReportCard extends StatelessWidget {
  const _PlayerReportCard({
    required this.emoji,
    required this.name,
    required this.isCorrect,
    required this.surface,
    required this.onCorrect,
    required this.onWrong,
  });

  final String emoji;
  final String name;
  final bool? isCorrect;
  final Color surface;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect == null
              ? Colors.transparent
              : isCorrect!
                  ? AppColors.success.withValues(alpha: 0.6)
                  : AppColors.loveRed.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        children: [
          Text('$emoji $name', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (isCorrect == null)
            Row(
              children: [
                Expanded(
                  child: _SmallButton(
                    label: 'Benar ✓',
                    color: AppColors.success,
                    onTap: onCorrect,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _SmallButton(
                    label: 'Salah ✗',
                    color: AppColors.loveRed,
                    onTap: onWrong,
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isCorrect!
                    ? AppColors.success.withValues(alpha: 0.2)
                    : AppColors.loveRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isCorrect! ? '✓ Benar! +15 XP' : '✗ Salah',
                style: TextStyle(
                  color: isCorrect! ? AppColors.success : AppColors.loveRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Final score
// ---------------------------------------------------------------------------

class _FinalScore extends StatelessWidget {
  const _FinalScore({
    required this.score1,
    required this.score2,
    required this.p1,
    required this.p2,
    required this.e1,
    required this.e2,
    required this.isAfterDark,
    required this.onRestart,
  });

  final int score1;
  final int score2;
  final String p1;
  final String p2;
  final String e1;
  final String e2;
  final bool isAfterDark;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final text = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final muted = isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final primary = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final surface = isAfterDark ? AppColors.darkCard : AppColors.normalCard;

    String winner;
    String winnerEmoji;
    if (score1 > score2) {
      winner = '$e1 $p1';
      winnerEmoji = '🏆';
    } else if (score2 > score1) {
      winner = '$e2 $p2';
      winnerEmoji = '🏆';
    } else {
      winner = 'Seri!';
      winnerEmoji = '🤝';
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎉', style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              'Game Selesai!',
              style: TextStyle(color: text, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$winnerEmoji Pemenang: $winner',
              style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _FinalPlayerScore(emoji: e1, name: p1, score: score1, textColor: text, primary: primary),
                  Container(width: 1, height: 60, color: primary.withValues(alpha: 0.3)),
                  _FinalPlayerScore(emoji: e2, name: p2, score: score2, textColor: text, primary: primary),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Total ${_lyrics.length} lagu telah ditebak!',
              style: TextStyle(color: muted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            GradientButton(
              onPressed: onRestart,
              child: const Text('🔄 Main Lagi',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinalPlayerScore extends StatelessWidget {
  const _FinalPlayerScore({
    required this.emoji,
    required this.name,
    required this.score,
    required this.textColor,
    required this.primary,
  });

  final String emoji;
  final String name;
  final int score;
  final Color textColor;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        Text(name, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
        Text('$score pts',
            style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 22)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------