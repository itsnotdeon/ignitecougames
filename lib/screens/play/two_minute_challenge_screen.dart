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
// Model
// ---------------------------------------------------------------------------

class GameChallenge {
  final String text;
  const GameChallenge({required this.text});
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class TwoMinuteChallengeScreen extends StatefulWidget {
  const TwoMinuteChallengeScreen({super.key});

  @override
  State<TwoMinuteChallengeScreen> createState() =>
      _TwoMinuteChallengeScreenState();
}

class _TwoMinuteChallengeScreenState extends State<TwoMinuteChallengeScreen>
    with TickerProviderStateMixin {
  static const int _totalSeconds = 120;
  static const int _xpReward = 25;

  static const List<GameChallenge> _challenges = [
    GameChallenge(
        text:
            'Tatap mata pasanganmu tanpa berkedip selama mungkin — siapa yang bertahan paling lama? 👀'),
    GameChallenge(
        text:
            'Pijat pundak pasanganmu dengan lembut sambil ia memejamkan mata 💆'),
    GameChallenge(
        text:
            'Berikan 10 kecupan kecil di berbagai bagian wajah pasanganmu 💋'),
    GameChallenge(
        text:
            'Duduk saling membelakangi dan ceritakan hal paling lucu yang pernah kalian alami 😂'),
    GameChallenge(
        text:
            'Berdansa perlahan berdua dengan lagu favorit — tanpa musik juga boleh! 💃'),
    GameChallenge(
        text: 'Saling sikat rambut pasanganmu dengan lembut 🪮'),
    GameChallenge(
        text:
            'Bacakan puisi singkat untuknya — boleh dibuat sendiri di saat itu 📝'),
    GameChallenge(
        text:
            'Gambar wajah pasanganmu (semirip mungkin) di kertas — bandingkan hasilnya! 🎨'),
    GameChallenge(
        text:
            'Tebak ekspresi: bergantian membuat ekspresi wajah tanpa bicara, pasangan tebak emosinya 🎭'),
    GameChallenge(
        text:
            'Buat origami sederhana bersama menggunakan 1 lembar kertas 📄'),
    GameChallenge(
        text:
            'Tutup mata — raba tangan pasanganmu dan ceritakan apa yang kamu rasakan 🤲'),
    GameChallenge(
        text:
            'Bernyanyi bersama lagu yang kalian sama-sama hafal — walaupun fals! 🎵'),
    GameChallenge(
        text:
            'Foto selfie pasangan terbaikmu hari ini — pose sekreatif mungkin 📸'),
    GameChallenge(
        text:
            'Saling memberi hadiah khayalan seharga \$1 juta — jelaskan hadiahnya! 🎁'),
    GameChallenge(
        text:
            'Duduk berhadapan, taruh tangan di dada pasangan, rasakan detak jantungnya selama 1 menit ❤️'),
    GameChallenge(
        text:
            'Bergantian ceritakan 5 hal yang kalian kagumi dari satu sama lain ✨'),
    GameChallenge(
        text:
            'Buat handshake rahasia baru kalian berdua yang unik 🤝'),
    GameChallenge(
        text:
            'Pejamkan mata, bayangkan 5 tahun ke depan, ceritakan apa yang kalian lihat 🔮'),
    GameChallenge(
        text:
            'Buat daftar 10 tempat yang ingin kalian kunjungi bersama — siapa paling banyak ide 🗺️'),
    GameChallenge(
        text:
            'Berbisik bergantian: ungkapkan 1 hal yang belum pernah kamu sampaikan sebelumnya 🤫'),
  ];

  late List<GameChallenge> _shuffled;
  int _challengeIndex = 0;
  int _timerSeconds = _totalSeconds;
  bool _isRunning = false;
  bool _isComplete = false;
  Timer? _timer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _shuffled = List<GameChallenge>.from(_challenges)..shuffle(Random());

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  GameChallenge get _currentChallenge => _shuffled[_challengeIndex];

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isComplete = false;
      _timerSeconds = _totalSeconds;
    });
    _timer?.cancel();
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
          _isRunning = false;
          _isComplete = true;
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _timerSeconds = _totalSeconds;
    });
  }

  void _completeChallenge() {
    _timer?.cancel();
    context.read<BondProvider>().addXp(_xpReward);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🎉 Tantangan selesai! +$_xpReward XP'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    setState(() {
      _isRunning = false;
      _isComplete = false;
      _timerSeconds = _totalSeconds;
      _challengeIndex = (_challengeIndex + 1) % _shuffled.length;
    });
  }

  void _skipChallenge() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isComplete = false;
      _timerSeconds = _totalSeconds;
      _challengeIndex = (_challengeIndex + 1) % _shuffled.length;
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
    final couple = context.watch<CoupleProvider>().profile;

    final primaryColor =
        isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final textColor =
        isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor =
        isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;

    final double progress =
        _totalSeconds > 0 ? _timerSeconds / _totalSeconds : 0;

    final bool isLow = _timerSeconds <= 15 && _isRunning;
    final Color timerColor =
        isLow ? AppColors.loveRed : primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('2-Minute Challenge ⏱️'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // --- Partner banner ---
              CustomCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(couple.emoji1,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Text(
                      '${couple.partner1} & ${couple.partner2}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(couple.emoji2,
                        style: const TextStyle(fontSize: 20)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- Challenge card ---
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: double.infinity,
                padding: const EdgeInsets.all(26),
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
                  border: Border.all(
                    color: primaryColor,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '🎯 TANTANGAN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.3,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _currentChallenge.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Reward: +$_xpReward XP',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isAfterDark
                            ? AppColors.darkAccent
                            : AppColors.normalSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // --- Circular timer ---
              ScaleTransition(
                scale: isLow ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          backgroundColor:
                              timerColor.withValues(alpha: 0.15),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(timerColor),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(_timerSeconds),
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: timerColor,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                          Text(
                            _isComplete
                                ? '🎉 Selesai!'
                                : _isRunning
                                    ? 'Berjalan...'
                                    : 'Siap?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // --- Action buttons ---
              if (_isComplete) ...[
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    text: 'Selesai! Ambil +$_xpReward XP 🎉',
                    icon: Icons.check_circle_rounded,
                    onPressed: _completeChallenge,
                  ),
                ),
              ] else if (_isRunning) ...[
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    text: 'Hentikan Timer',
                    icon: Icons.stop_rounded,
                    isSecondary: true,
                    onPressed: _stopTimer,
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    text: 'Mulai Tantangan ▶',
                    icon: Icons.play_arrow_rounded,
                    onPressed: _startTimer,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: 'Lewati Tantangan',
                  icon: Icons.skip_next_rounded,
                  isSecondary: true,
                  onPressed: _skipChallenge,
                ),
              ),

              const SizedBox(height: 16),

              // --- Challenge counter ---
              Text(
                'Tantangan ${_challengeIndex + 1} / ${_shuffled.length}',
                style: TextStyle(
                  fontSize: 13,
                  color: mutedColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}