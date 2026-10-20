import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/bond_provider.dart';
import '../../providers/couple_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_card.dart';

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

enum CharadesCategory { romantic, everyday, funny }

extension CharadesCategoryLabel on CharadesCategory {
  String get label {
    switch (this) {
      case CharadesCategory.romantic:
        return '💕 Romantic';
      case CharadesCategory.everyday:
        return '🏠 Everyday';
      case CharadesCategory.funny:
        return '😂 Funny';
    }
  }

  Color get color {
    switch (this) {
      case CharadesCategory.romantic:
        return AppColors.loveRed;
      case CharadesCategory.everyday:
        return AppColors.normalSecondary;
      case CharadesCategory.funny:
        return AppColors.gold;
    }
  }
}

const Map<CharadesCategory, List<String>> _wordMap = {
  CharadesCategory.romantic: [
    'Cinta Pertama',
    'Ciuman',
    'Bunga Mawar',
    'Cincin Berlian',
    'Kencan Malam',
    'Pelukan Hangat',
    'Foto Bareng',
    'Senyum Manis',
    'Tarian Waltz',
    'Surat Cinta',
  ],
  CharadesCategory.everyday: [
    'Masak Bareng',
    'Nonton Film',
    'Jalan-Jalan',
    'Beli Kopi',
    'Main Kucing',
    'Tidur Siang',
    'Baca Buku',
    'Main Musik',
    'Olahraga',
    'Belanja Grocery',
  ],
  CharadesCategory.funny: [
    'Cemburu',
    'Ngambek',
    'Minta Maaf',
    'Muka Mabuk',
    'Nangis Bahagia',
    'Selfie Narsis',
    'Gombal Gagal',
    'Jatuh Cinta',
    'Kepergok Bucin',
    'Chat Tengah Malam',
  ],
};

// ---------------------------------------------------------------------------
// Enums & State
// ---------------------------------------------------------------------------

enum CharadesPhase { selectCategory, acting, result }

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class CoupleCharadesScreen extends StatefulWidget {
  const CoupleCharadesScreen({super.key});

  @override
  State<CoupleCharadesScreen> createState() => _CoupleCharadesScreenState();
}

class _CoupleCharadesScreenState extends State<CoupleCharadesScreen>
    with SingleTickerProviderStateMixin {
  static const int _timerTotal = 60;
  static const int _xpPerGuess = 10;

  CharadesCategory? _selectedCategory;
  CharadesPhase _phase = CharadesPhase.selectCategory;

  List<String> _words = [];
  int _wordIndex = 0;
  int _correctGuesses = 0;
  int _wrongGuesses = 0;

  int _timerSeconds = _timerTotal;
  bool _timerRunning = false;
  Timer? _timer;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bounceController.dispose();
    super.dispose();
  }

  void _selectCategory(CharadesCategory category) {
    final shuffled = List<String>.from(_wordMap[category]!)..shuffle(Random());
    setState(() {
      _selectedCategory = category;
      _words = shuffled;
      _wordIndex = 0;
      _correctGuesses = 0;
      _wrongGuesses = 0;
      _timerSeconds = _timerTotal;
      _timerRunning = false;
      _phase = CharadesPhase.acting;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timerRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          t.cancel();
          _timerRunning = false;
          _phase = CharadesPhase.result;
        }
      });
    });
  }

  void _markGuess(bool correct) {
    _bounceController.forward().then((_) => _bounceController.reverse());
    if (correct) {
      context.read<BondProvider>().addXp(_xpPerGuess);
    }
    setState(() {
      if (correct) {
        _correctGuesses++;
      } else {
        _wrongGuesses++;
      }
      if (_wordIndex < _words.length - 1) {
        _wordIndex++;
      } else {
        _timer?.cancel();
        _timerRunning = false;
        _phase = CharadesPhase.result;
      }
    });
  }

  void _resetGame() {
    _timer?.cancel();
    setState(() {
      _selectedCategory = null;
      _phase = CharadesPhase.selectCategory;
      _words = [];
      _wordIndex = 0;
      _correctGuesses = 0;
      _wrongGuesses = 0;
      _timerSeconds = _timerTotal;
      _timerRunning = false;
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Couple Charades 🎭'),
        centerTitle: true,
        actions: [
          if (_phase != CharadesPhase.selectCategory)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _resetGame,
              tooltip: 'Mulai Ulang',
            ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: switch (_phase) {
            CharadesPhase.selectCategory =>
              _buildCategorySelect(isAfterDark),
            CharadesPhase.acting => _buildActingPhase(isAfterDark),
            CharadesPhase.result => _buildResultPhase(isAfterDark),
          },
        ),
      ),
    );
  }

  // --- Category selection ---

  Widget _buildCategorySelect(bool isAfterDark) {
    final couple = context.watch<CoupleProvider>().profile;
    final primaryColor =
        isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;

    return SingleChildScrollView(
      key: const ValueKey('select'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          CustomCard(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                const Text('🎭', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 10),
                Text(
                  'Couple Charades',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${couple.partner1} & ${couple.partner2} — bergiliran berakting!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isAfterDark
                        ? AppColors.darkTextMuted
                        : AppColors.normalTextMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Pilih Kategori',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isAfterDark ? AppColors.darkText : AppColors.normalText,
            ),
          ),
          const SizedBox(height: 16),
          ...CharadesCategory.values.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCategoryCard(cat, isAfterDark),
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📖 Cara Bermain',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _ruleItem('Pemain aktif melihat kata, pasangan berpaling'),
                _ruleItem('Perankan kata tanpa bicara atau bersuara'),
                _ruleItem('Pasangan menebak dalam 60 detik'),
                _ruleItem('Ketuk ✓ Benar atau ✗ Salah setelah tebakan'),
                _ruleItem('+$_xpPerGuess XP untuk setiap tebakan benar'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ruleItem(String text) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: isAfterDark
                  ? AppColors.darkAccent
                  : AppColors.normalPrimary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isAfterDark
                    ? AppColors.darkTextMuted
                    : AppColors.normalTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(CharadesCategory cat, bool isAfterDark) {
    final color = cat.color;
    return GestureDetector(
      onTap: () => _selectCategory(cat),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  cat.label.split(' ').first,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.label.substring(cat.label.indexOf(' ') + 1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isAfterDark
                          ? AppColors.darkText
                          : AppColors.normalText,
                    ),
                  ),
                  Text(
                    '${_wordMap[cat]!.length} kata siap diperankan',
                    style: TextStyle(
                      fontSize: 12,
                      color: isAfterDark
                          ? AppColors.darkTextMuted
                          : AppColors.normalTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  // --- Acting phase ---

  Widget _buildActingPhase(bool isAfterDark) {
    final primaryColor =
        isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final textColor =
        isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor =
        isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;

    final bool isLow = _timerSeconds <= 10 && _timerRunning;
    final timerColor = isLow ? AppColors.loveRed : primaryColor;
    final double timerProgress =
        _timerTotal > 0 ? _timerSeconds / _timerTotal : 0;

    return Padding(
      key: const ValueKey('acting'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Timer + score row
          Row(
            children: [
              Expanded(
                child: CustomCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        _formatTime(_timerSeconds),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: timerColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: timerProgress,
                        backgroundColor: timerColor.withValues(alpha: 0.15),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(timerColor),
                        borderRadius: BorderRadius.circular(6),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            '$_correctGuesses',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                          Text('Benar',
                              style: TextStyle(
                                  fontSize: 11, color: mutedColor)),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 32,
                        color: isAfterDark
                            ? AppColors.darkBorder
                            : AppColors.normalBorder,
                      ),
                      Column(
                        children: [
                          Text(
                            '$_wrongGuesses',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.loveRed,
                            ),
                          ),
                          Text('Salah',
                              style: TextStyle(
                                  fontSize: 11, color: mutedColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Word card
          Expanded(
            child: ScaleTransition(
              scale: _bounceAnim,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: isAfterDark
                      ? const LinearGradient(
                          colors: [Color(0xFF281438), Color(0xFF190B24)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFFFFFFF), Color(0xFFFFF0F3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: primaryColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _selectedCategory?.label.split(' ').first ?? '🎭',
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Perankan Ini!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _timerRunning || _wordIndex > 0
                          ? _words[_wordIndex]
                          : '???',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_wordIndex + 1} / ${_words.length}',
                      style: TextStyle(fontSize: 13, color: mutedColor),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          if (!_timerRunning && _wordIndex == 0)
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'Mulai Timer ▶',
                icon: Icons.play_arrow_rounded,
                onPressed: _startTimer,
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _markGuess(false),
                    child: Container(
                      height: 62,
                      decoration: BoxDecoration(
                        color: AppColors.loveRed.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.loveRed.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '✗  Salah',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.loveRed,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _markGuess(true),
                    child: Container(
                      height: 62,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '✓  Benar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // --- Result phase ---

  Widget _buildResultPhase(bool isAfterDark) {
    final primaryColor =
        isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final textColor =
        isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor =
        isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final totalXp = _correctGuesses * _xpPerGuess;

    return SingleChildScrollView(
      key: const ValueKey('result'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Ronde Selesai!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _correctGuesses > 5
                ? 'Luar biasa! Kalian sehati banget 💕'
                : 'Tetap semangat, latihan membuat sempurna!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: mutedColor),
          ),
          const SizedBox(height: 28),
          CustomCard(
            child: Column(
              children: [
                _resultRow('✅ Tebakan Benar', '$_correctGuesses',
                    AppColors.success),
                const Divider(height: 20),
                _resultRow(
                    '❌ Tebakan Salah', '$_wrongGuesses', AppColors.loveRed),
                const Divider(height: 20),
                _resultRow('⭐ XP Didapat', '+$totalXp XP', primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              text: 'Main Lagi 🔄',
              icon: Icons.refresh_rounded,
              onPressed: _resetGame,
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, Color valueColor) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isAfterDark
                ? AppColors.darkTextMuted
                : AppColors.normalTextMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}