import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/bond_provider.dart';
import '../../providers/couple_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/gradient_button.dart';

// ─────────────────────────────────────────────
//  Data
// ─────────────────────────────────────────────
class _QuestionPair {
  final String left;
  final String right;
  const _QuestionPair(this.left, this.right);
}

const List<_QuestionPair> _questions = [
  _QuestionPair('Pantai 🌊', 'Gunung ⛰️'),
  _QuestionPair('Film Romantis 🎬', 'Film Horor 😱'),
  _QuestionPair('Makan Malam Mewah 🍽️', 'Piknik di Taman 🧺'),
  _QuestionPair('Liburan ke Eropa ✈️', 'Staycation di Rumah 🏠'),
  _QuestionPair('Bangun Pagi 🌅', 'Tidur Siang 😴'),
  _QuestionPair('Hujan 🌧️', 'Cerah ☀️'),
  _QuestionPair('Kopi ☕', 'Teh 🍵'),
  _QuestionPair('Chat Dulu 💬', 'Telepon Langsung 📞'),
  _QuestionPair('Surprise Date 🎁', 'Date Terencana 📅'),
  _QuestionPair('Rumah Besar 🏡', 'Apartemen Cozy 🏢'),
  _QuestionPair('Adopsi Kucing 🐱', 'Adopsi Anjing 🐶'),
  _QuestionPair('Road Trip 🚗', 'Naik Pesawat ✈️'),
  _QuestionPair('Masak Berdua 👨‍🍳', 'Order Makanan 📱'),
  _QuestionPair('Gym Bersama 💪', 'Yoga Santai 🧘'),
  _QuestionPair('Nonton di Bioskop 🎭', 'Netflix di Kasur 📺'),
];

const _discussionPrompts = [
  'Ceritakan kenapa kamu memilih itu! 💬',
  'Kapan terakhir kalian mencoba pilihan yang berbeda bersama? 🤔',
  'Gimana kalau kalian coba pilihan pasanganmu minggu depan? 😄',
  'Perbedaan ini justru bikin kalian menarik! Apa yang bisa kalian pelajari? ✨',
  'Diskusikan: kapan waktu terbaik untuk mencoba pilihan masing-masing? 📅',
];

const int _totalRounds = 10;
const int _xpPerRound = 20;

// ─────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────
class ThisOrThatScreen extends StatefulWidget {
  const ThisOrThatScreen({super.key});

  @override
  State<ThisOrThatScreen> createState() => _ThisOrThatScreenState();
}

class _ThisOrThatScreenState extends State<ThisOrThatScreen>
    with TickerProviderStateMixin {
  int _currentQuestion = 0;
  String? _player1Choice;
  String? _player2Choice;
  int _player1Score = 0;
  int _player2Score = 0;
  bool _roundComplete = false;
  int _totalXp = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  _QuestionPair get _currentPair =>
      _questions[_currentQuestion % _questions.length];

  bool get _bothChosen => _player1Choice != null && _player2Choice != null;
  bool get _isSameChoice => _player1Choice == _player2Choice;

  String get _discussionPrompt =>
      _discussionPrompts[_currentQuestion % _discussionPrompts.length];

  void _handleChoice(int player, String choice) {
    if (_roundComplete) return;
    if (player == 1 && _player1Choice != null) return;
    if (player == 2 && _player2Choice != null) return;

    setState(() {
      if (player == 1) {
        _player1Choice = choice;
      } else {
        _player2Choice = choice;
      }

      if (_bothChosen) {
        _roundComplete = true;
        if (_isSameChoice) {
          _player1Score++;
          _player2Score++;
        }
        context.read<BondProvider>().addXp(_xpPerRound);
        _totalXp += _xpPerRound;
      }
    });
  }

  void _nextRound() {
    if (_currentQuestion + 1 >= _totalRounds) {
      _showResultDialog();
      return;
    }
    _fadeController.reset();
    setState(() {
      _currentQuestion++;
      _player1Choice = null;
      _player2Choice = null;
      _roundComplete = false;
    });
    _fadeController.forward();
  }

  void _showResultDialog() {
    final isAfterDark = context.read<AppProvider>().isAfterDark;
    final coupleProfile = context.read<CoupleProvider>().profile;
    final p1Name = coupleProfile.partner1.isNotEmpty ? coupleProfile.partner1 : 'Player 1';
    final p2Name = coupleProfile.partner2.isNotEmpty ? coupleProfile.partner2 : 'Player 2';
    final sameCount = _player1Score;
    final pct = (sameCount / _totalRounds * 100).round();

    String message;
    if (pct >= 80) {
      message = 'Kalian super sehati! 💕\nPilihan kalian hampir selalu sama.';
    } else if (pct >= 50) {
      message = 'Cukup sehati! 🌸\nPerbedaan kalian justru bikin seru.';
    } else {
      message = 'Banyak perbedaan! 🎉\nIni kesempatan untuk saling mengenal lebih dalam.';
    }

    final bgColor = isAfterDark ? AppColors.darkSurface : AppColors.normalSurface;
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final primaryColor = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎊', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              Text(
                'Game Selesai!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$pct% Sehati',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: textColor, height: 1.5),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ScoreChip(name: p1Name, score: _player1Score, isAfterDark: isAfterDark),
                  const SizedBox(width: 12),
                  _ScoreChip(name: p2Name, score: _player2Score, isAfterDark: isAfterDark),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '+$_totalXp XP earned! ⭐',
                style: TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: 'Selesai',
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;
    final coupleProfile = context.watch<CoupleProvider>().profile;
    final p1Name = coupleProfile.partner1.isNotEmpty ? coupleProfile.partner1 : 'Player 1';
    final p2Name = coupleProfile.partner2.isNotEmpty ? coupleProfile.partner2 : 'Player 2';

    final bgTop = isAfterDark ? AppColors.darkBgTop : AppColors.normalBgTop;
    final bgBottom = isAfterDark ? AppColors.darkBgBottom : AppColors.normalBgBottom;
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor = isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final primaryColor = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;

    return Scaffold(
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
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18, color: primaryColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This or That 💕',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            'Couple Edition',
                            style: TextStyle(fontSize: 12, color: mutedColor),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentQuestion + 1} / $_totalRounds',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentQuestion + 1) / _totalRounds,
                    backgroundColor: primaryColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    minHeight: 6,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Main content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Question header
                        CustomCard(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'Pilih salah satu! Masing-masing pilih secara bersamaan 🙈',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: mutedColor,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Choice cards
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _ChoiceColumn(
                                playerName: p1Name,
                                choice: _currentPair.left,
                                isSelected: _player1Choice == _currentPair.left,
                                isRevealed: _roundComplete,
                                isAfterDark: isAfterDark,
                                onTap: () => _handleChoice(1, _currentPair.left),
                                playerColor: primaryColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'VS',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: _ChoiceColumn(
                                playerName: p2Name,
                                choice: _currentPair.right,
                                isSelected: _player2Choice == _currentPair.right,
                                isRevealed: _roundComplete,
                                isAfterDark: isAfterDark,
                                onTap: () => _handleChoice(2, _currentPair.right),
                                playerColor:
                                    isAfterDark ? AppColors.darkSecondary : AppColors.normalSecondary,
                              ),
                            ),
                          ],
                        ),

                        // Also allow cross-picks
                        if (!_roundComplete) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _MiniChoiceButton(
                                  label: _currentPair.right,
                                  chosen: _player1Choice == _currentPair.right,
                                  onTap: () => _handleChoice(1, _currentPair.right),
                                  isAfterDark: isAfterDark,
                                  primaryColor: primaryColor,
                                  hint: 'Atau pilih ini, ${p1Name.split(' ').first}',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _MiniChoiceButton(
                                  label: _currentPair.left,
                                  chosen: _player2Choice == _currentPair.left,
                                  onTap: () => _handleChoice(2, _currentPair.left),
                                  isAfterDark: isAfterDark,
                                  primaryColor: isAfterDark
                                      ? AppColors.darkSecondary
                                      : AppColors.normalSecondary,
                                  hint: 'Atau pilih ini, ${p2Name.split(' ').first}',
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Result area
                        if (_roundComplete) ...[
                          _ResultBanner(
                            isSame: _isSameChoice,
                            p1Choice: _player1Choice!,
                            p2Choice: _player2Choice!,
                            p1Name: p1Name,
                            p2Name: p2Name,
                            discussionPrompt: _discussionPrompt,
                            isAfterDark: isAfterDark,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: GradientButton(
                              text: _currentQuestion + 1 >= _totalRounds
                                  ? 'Lihat Hasil 🎊'
                                  : 'Pertanyaan Selanjutnya →',
                              onPressed: _nextRound,
                            ),
                          ),
                        ],

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Sub-widgets
// ─────────────────────────────────────────────

class _ChoiceColumn extends StatelessWidget {
  final String playerName;
  final String choice;
  final bool isSelected;
  final bool isRevealed;
  final bool isAfterDark;
  final VoidCallback onTap;
  final Color playerColor;

  const _ChoiceColumn({
    required this.playerName,
    required this.choice,
    required this.isSelected,
    required this.isRevealed,
    required this.isAfterDark,
    required this.onTap,
    required this.playerColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isAfterDark ? AppColors.darkCard : AppColors.normalCard;
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;

    final bool highlight = isSelected && isRevealed;

    return GestureDetector(
      onTap: isRevealed ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: highlight
              ? playerColor.withValues(alpha: 0.15)
              : isSelected
                  ? playerColor.withValues(alpha: 0.08)
                  : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? playerColor : (isAfterDark ? AppColors.darkBorder : AppColors.normalBorder),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? playerColor.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              playerName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: playerColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              choice,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (!isRevealed && !isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: playerColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Pilih ✓',
                  style: TextStyle(
                    color: playerColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: playerColor, size: 28),
          ],
        ),
      ),
    );
  }
}

class _MiniChoiceButton extends StatelessWidget {
  final String label;
  final bool chosen;
  final VoidCallback onTap;
  final bool isAfterDark;
  final Color primaryColor;
  final String hint;

  const _MiniChoiceButton({
    required this.label,
    required this.chosen,
    required this.onTap,
    required this.isAfterDark,
    required this.primaryColor,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor = isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    return GestureDetector(
      onTap: chosen ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: chosen ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: chosen ? primaryColor : mutedColor.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          hint,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: chosen ? primaryColor : mutedColor,
            fontWeight: chosen ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final bool isSame;
  final String p1Choice;
  final String p2Choice;
  final String p1Name;
  final String p2Name;
  final String discussionPrompt;
  final bool isAfterDark;

  const _ResultBanner({
    required this.isSame,
    required this.p1Choice,
    required this.p2Choice,
    required this.p1Name,
    required this.p2Name,
    required this.discussionPrompt,
    required this.isAfterDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final primaryColor = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            isSame ? '💞 Sehati!' : '🔀 Berbeda!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isSame ? AppColors.success : primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(p1Name,
                        style: TextStyle(
                            fontSize: 12,
                            color: isAfterDark
                                ? AppColors.darkTextMuted
                                : AppColors.normalTextMuted)),
                    const SizedBox(height: 4),
                    Text(p1Choice,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                  ],
                ),
              ),
              Icon(Icons.compare_arrows_rounded,
                  color: isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted),
              Expanded(
                child: Column(
                  children: [
                    Text(p2Name,
                        style: TextStyle(
                            fontSize: 12,
                            color: isAfterDark
                                ? AppColors.darkTextMuted
                                : AppColors.normalTextMuted)),
                    const SizedBox(height: 4),
                    Text(p2Choice,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                  ],
                ),
              ),
            ],
          ),
          if (!isSame) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
              ),
              child: Text(
                discussionPrompt,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: textColor, height: 1.5),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            '+$_xpPerRound XP ⭐',
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final String name;
  final int score;
  final bool isAfterDark;

  const _ScoreChip({
    required this.name,
    required this.score,
    required this.isAfterDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(name,
              style: TextStyle(
                  fontSize: 12,
                  color: isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted)),
          Text(
            '$score',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }
}