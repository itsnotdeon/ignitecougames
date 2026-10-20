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
class _Scenario {
  final String optionA;
  final String optionB;
  const _Scenario(this.optionA, this.optionB);
}

const List<_Scenario> _scenarios = [
  _Scenario(
    'Selalu jujur 100% walau menyakitkan',
    'Bohong kecil demi kebahagiaan pasangan',
  ),
  _Scenario(
    'Kencan mewah setiap bulan',
    'Kencan sederhana tapi setiap minggu',
  ),
  _Scenario(
    'Bisa membaca pikiran pasanganmu',
    'Pasangan bisa membaca pikiranmu',
  ),
  _Scenario(
    'Hidup bersama 50 tahun tanpa pernah bertengkar',
    'Hidup bersama 30 tahun penuh dengan cinta menggebu',
  ),
  _Scenario(
    'Menikah diam-diam tanpa pesta',
    'Pesta pernikahan besar dengan semua orang',
  ),
  _Scenario(
    'Pasangan sangat romantis tapi kurang ambisius',
    'Pasangan sangat sukses tapi kurang ekspresif',
  ),
  _Scenario(
    'Selalu bersama setiap saat',
    'Punya waktu me-time yang seimbang',
  ),
  _Scenario(
    'Liburan mewah sekali setahun',
    'Perjalanan pendek setiap bulan',
  ),
  _Scenario(
    'Pasangan masak setiap hari',
    'Makan di luar setiap hari',
  ),
  _Scenario(
    'Punya 3 anak',
    'Punya 1 anak tapi kasih berlimpah',
  ),
  _Scenario(
    'Tinggal di kota besar sibuk',
    'Tinggal di pinggiran kota yang tenang',
  ),
  _Scenario(
    'Pertengkaran cepat selesai',
    'Jarang bertengkar tapi dalam jika terjadi',
  ),
  _Scenario(
    'Pasangan yang suka kejutan',
    'Pasangan yang terencana dan konsisten',
  ),
  _Scenario(
    'Honeymoon ke Bali 🌴',
    'Honeymoon ke Paris 🗼',
  ),
  _Scenario(
    'Punya anjing besar',
    'Punya banyak kucing',
  ),
];

const _debatePrompts = [
  'Kenapa kamu pilih itu? Cerita lebih dong! 💬',
  'Ini menarik! Apakah pilihanmu berubah seiring waktu? 🤔',
  'Kalian beda pilihan! Siapa yang akan mengalah? 😄',
  'Diskusikan: bagaimana kalian menyeimbangkan perbedaan ini? ⚖️',
  'Menarik sekali! Gimana kalau kalian coba swap pilihan untuk sehari? 🔄',
];

const int _xpPerRound = 15;

// ─────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────
class WouldYouRatherScreen extends StatefulWidget {
  const WouldYouRatherScreen({super.key});

  @override
  State<WouldYouRatherScreen> createState() => _WouldYouRatherScreenState();
}

class _WouldYouRatherScreenState extends State<WouldYouRatherScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  String? _player1Choice;
  String? _player2Choice;
  bool _roundComplete = false;
  int _matchCount = 0;
  int _totalXp = 0;
  int _roundsPlayed = 0;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  _Scenario get _current => _scenarios[_currentIndex % _scenarios.length];
  bool get _bothChosen => _player1Choice != null && _player2Choice != null;
  bool get _isSameChoice => _player1Choice == _player2Choice;
  String get _debatePrompt =>
      _debatePrompts[_currentIndex % _debatePrompts.length];

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
        _roundsPlayed++;
        if (_isSameChoice) _matchCount++;
        context.read<BondProvider>().addXp(_xpPerRound);
        _totalXp += _xpPerRound;
      }
    });
  }

  void _nextRound() {
    if (_currentIndex + 1 >= _scenarios.length) {
      _showSummaryDialog();
      return;
    }
    _slideController.reset();
    setState(() {
      _currentIndex++;
      _player1Choice = null;
      _player2Choice = null;
      _roundComplete = false;
    });
    _slideController.forward();
  }

  void _showSummaryDialog() {
    final isAfterDark = context.read<AppProvider>().isAfterDark;
    final coupleProfile = context.read<CoupleProvider>().profile;
    final p1Name = coupleProfile.partner1.isNotEmpty ? coupleProfile.partner1 : 'Player 1';
    final p2Name = coupleProfile.partner2.isNotEmpty ? coupleProfile.partner2 : 'Player 2';
    final total = _roundsPlayed;
    final pct = total > 0 ? (_matchCount / total * 100).round() : 0;

    String message;
    String emoji;
    if (pct >= 80) {
      message = 'Pikiran kalian sangat sejalan! 🔥';
      emoji = '🏆';
    } else if (pct >= 50) {
      message = 'Ada kesamaan, ada perbedaan — itulah yang membuat hubungan kalian unik!';
      emoji = '💞';
    } else {
      message = 'Banyak perbedaan yang seru untuk didiskusikan lebih lanjut! 🗣️';
      emoji = '🎭';
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
              Text(emoji, style: const TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              Text(
                'Game Selesai!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '$pct% Sependapat',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                    Text(
                      '$_matchCount dari $total putaran sama',
                      style: TextStyle(fontSize: 13, color: isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: textColor, height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                '+$_totalXp XP earned! ⭐',
                style: const TextStyle(
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
    final secondaryColor = isAfterDark ? AppColors.darkSecondary : AppColors.normalSecondary;
    final totalScenarios = _scenarios.length;

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
                            'Would You Rather 🤔',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text('Couple Edition',
                              style: TextStyle(fontSize: 12, color: mutedColor)),
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
                        '${_currentIndex + 1} / $totalScenarios',
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
                    value: (_currentIndex + 1) / totalScenarios,
                    backgroundColor: primaryColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    minHeight: 6,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Header chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor.withValues(alpha: 0.8),
                                secondaryColor.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Would You Rather...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Option A — Player 1
                        _ScenarioCard(
                          playerName: p1Name,
                          option: _current.optionA,
                          label: 'A',
                          isSelected: _player1Choice == _current.optionA,
                          otherSelected: _player2Choice == _current.optionA,
                          isRevealed: _roundComplete,
                          isAfterDark: isAfterDark,
                          onP1Tap: () => _handleChoice(1, _current.optionA),
                          onP2Tap: () => _handleChoice(2, _current.optionA),
                          p1Name: p1Name,
                          p2Name: p2Name,
                          primaryColor: primaryColor,
                          secondaryColor: secondaryColor,
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: isAfterDark
                                    ? AppColors.darkBorder
                                    : AppColors.normalBorder,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'atau',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: mutedColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Option B — Player 2
                        _ScenarioCard(
                          playerName: p2Name,
                          option: _current.optionB,
                          label: 'B',
                          isSelected: _player2Choice == _current.optionB,
                          otherSelected: _player1Choice == _current.optionB,
                          isRevealed: _roundComplete,
                          isAfterDark: isAfterDark,
                          onP1Tap: () => _handleChoice(1, _current.optionB),
                          onP2Tap: () => _handleChoice(2, _current.optionB),
                          p1Name: p1Name,
                          p2Name: p2Name,
                          primaryColor: secondaryColor,
                          secondaryColor: primaryColor,
                        ),

                        const SizedBox(height: 20),

                        // Status chips
                        if (!_roundComplete)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _StatusChip(
                                name: p1Name,
                                chosen: _player1Choice != null,
                                isAfterDark: isAfterDark,
                                primaryColor: primaryColor,
                              ),
                              const SizedBox(width: 12),
                              _StatusChip(
                                name: p2Name,
                                chosen: _player2Choice != null,
                                isAfterDark: isAfterDark,
                                primaryColor: secondaryColor,
                              ),
                            ],
                          ),

                        // Result
                        if (_roundComplete) ...[
                          _WyrResultBanner(
                            isSame: _isSameChoice,
                            p1Choice: _player1Choice!,
                            p2Choice: _player2Choice!,
                            p1Name: p1Name,
                            p2Name: p2Name,
                            debatePrompt: _debatePrompt,
                            isAfterDark: isAfterDark,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: GradientButton(
                              text: _currentIndex + 1 >= totalScenarios
                                  ? 'Lihat Ringkasan 🎊'
                                  : 'Skenario Berikutnya →',
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

class _ScenarioCard extends StatelessWidget {
  final String playerName;
  final String option;
  final String label;
  final bool isSelected;
  final bool otherSelected;
  final bool isRevealed;
  final bool isAfterDark;
  final VoidCallback onP1Tap;
  final VoidCallback onP2Tap;
  final String p1Name;
  final String p2Name;
  final Color primaryColor;
  final Color secondaryColor;

  const _ScenarioCard({
    required this.playerName,
    required this.option,
    required this.label,
    required this.isSelected,
    required this.otherSelected,
    required this.isRevealed,
    required this.isAfterDark,
    required this.onP1Tap,
    required this.onP2Tap,
    required this.p1Name,
    required this.p2Name,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isAfterDark ? AppColors.darkCard : AppColors.normalCard;
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final borderColor = isAfterDark ? AppColors.darkBorder : AppColors.normalBorder;

    final anySelected = isSelected || otherSelected;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: anySelected ? primaryColor.withValues(alpha: 0.08) : cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: anySelected ? primaryColor : borderColor,
          width: anySelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: anySelected
                ? primaryColor.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            if (!isRevealed) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _TapButton(
                      label: p1Name,
                      chosen: isSelected,
                      color: primaryColor,
                      onTap: onP1Tap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TapButton(
                      label: p2Name,
                      chosen: otherSelected,
                      color: secondaryColor,
                      onTap: onP2Tap,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (isSelected)
                    _PlayerBadge(name: p1Name, color: primaryColor),
                  if (isSelected && otherSelected) const SizedBox(width: 8),
                  if (otherSelected)
                    _PlayerBadge(name: p2Name, color: secondaryColor),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TapButton extends StatelessWidget {
  final String label;
  final bool chosen;
  final Color color;
  final VoidCallback onTap;

  const _TapButton({
    required this.label,
    required this.chosen,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: chosen ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: chosen ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: chosen ? 0.6 : 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (chosen)
              Icon(Icons.check_circle_rounded, size: 14, color: color),
            if (chosen) const SizedBox(width: 4),
            Text(
              chosen ? 'Dipilih ✓' : label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerBadge extends StatelessWidget {
  final String name;
  final Color color;

  const _PlayerBadge({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String name;
  final bool chosen;
  final bool isAfterDark;
  final Color primaryColor;

  const _StatusChip({
    required this.name,
    required this.chosen,
    required this.isAfterDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor = isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: chosen ? primaryColor.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: chosen ? primaryColor : mutedColor.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            chosen ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 14,
            color: chosen ? primaryColor : mutedColor,
          ),
          const SizedBox(width: 6),
          Text(
            chosen ? '$name sudah pilih' : '$name belum pilih',
            style: TextStyle(
              color: chosen ? primaryColor : mutedColor,
              fontWeight: chosen ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _WyrResultBanner extends StatelessWidget {
  final bool isSame;
  final String p1Choice;
  final String p2Choice;
  final String p1Name;
  final String p2Name;
  final String debatePrompt;
  final bool isAfterDark;

  const _WyrResultBanner({
    required this.isSame,
    required this.p1Choice,
    required this.p2Choice,
    required this.p1Name,
    required this.p2Name,
    required this.debatePrompt,
    required this.isAfterDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final primaryColor = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final mutedColor = isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            isSame ? '💞 Sependapat!' : '🔥 Beda Pendapat!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isSame ? AppColors.success : primaryColor,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(p1Name,
                        style: TextStyle(fontSize: 12, color: mutedColor)),
                    const SizedBox(height: 4),
                    Text(
                      p1Choice.length > 30
                          ? '${p1Choice.substring(0, 30)}...'
                          : p1Choice,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('🆚', style: TextStyle(fontSize: 20)),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(p2Name,
                        style: TextStyle(fontSize: 12, color: mutedColor)),
                    const SizedBox(height: 4),
                    Text(
                      p2Choice.length > 30
                          ? '${p2Choice.substring(0, 30)}...'
                          : p2Choice,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.3,
                      ),
                    ),
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
                debatePrompt,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: textColor, height: 1.5),
              ),
            ),
          ],
          const SizedBox(height: 10),
          const Text(
            '+$_xpPerRound XP ⭐',
            style: TextStyle(
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