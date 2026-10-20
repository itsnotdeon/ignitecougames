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
const List<String> _questions = [
  'Apa makanan favorit pasanganmu?',
  'Warna apa yang paling ia suka?',
  'Film apa yang selalu bisa ia tonton berulang?',
  'Apa hobinya yang jarang kamu tau?',
  'Lagu apa yang sering ia dengarkan?',
  'Apa mimpi terbesarnya dalam hidup?',
  'Siapa idola atau tokoh inspirasinya?',
  'Apa kebiasaan paginya setelah bangun tidur?',
  'Apa ketakutan terbesarnya?',
  'Bagaimana cara ia melepas stres?',
  'Apa pencapaian yang paling ia banggakan?',
  'Hidangan apa yang ia benci?',
  'Musim apa yang ia sukai?',
  'Apa playlist favorit ia saat berkendara?',
  'Di mana tempat favoritnya menghabiskan waktu?',
  'Apa yang ia lakukan saat bosan?',
  'Siapa teman terdekatnya selain kamu?',
  'Apa hal kecil yang sering membuatnya tertawa?',
  'Apa skill tersembunyi yang ia miliki?',
  'Jika bisa ke mana saja sekarang, ke mana ia pergi?',
];

const int _xpPerCorrect = 5;

enum _GamePhase { answer, verify, result }

const List<String> _encouragements = [
  'Kalian luar biasa saling mengenal! 💞',
  'Kamu benar-benar memperhatikan pasanganmu! 🌟',
  'Cinta kalian terlihat dari seberapa kamu kenal dia! 💕',
  'Hubungan yang kuat dimulai dari saling memahami! 🔥',
  'Kalian memang ditakdirkan untuk saling mengenal! ✨',
];

// ─────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────
class KnowYourPartnerScreen extends StatefulWidget {
  const KnowYourPartnerScreen({super.key});

  @override
  State<KnowYourPartnerScreen> createState() => _KnowYourPartnerScreenState();
}

class _KnowYourPartnerScreenState extends State<KnowYourPartnerScreen>
    with TickerProviderStateMixin {
  _GamePhase _phase = _GamePhase.answer;
  int _currentIndex = 0;
  final List<String> _answers = List.filled(_questions.length, '');
  final List<bool?> _verifications = List.filled(_questions.length, null);
  final TextEditingController _textController = TextEditingController();
  int _correctCount = 0;
  int _totalXp = 0;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
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
    _textController.dispose();
    super.dispose();
  }

  void _submitAnswer() {
    final answer = _textController.text.trim();
    if (answer.isEmpty) return;

    setState(() {
      _answers[_currentIndex] = answer;
      _textController.clear();

      if (_currentIndex + 1 >= _questions.length) {
        _phase = _GamePhase.verify;
        _currentIndex = 0;
      } else {
        _currentIndex++;
      }
    });
    _animateTransition();
  }

  void _submitVerification(bool isCorrect) {
    setState(() {
      _verifications[_currentIndex] = isCorrect;
      if (isCorrect) {
        _correctCount++;
        _totalXp += _xpPerCorrect;
        context.read<BondProvider>().addXp(_xpPerCorrect);
      }

      if (_currentIndex + 1 >= _questions.length) {
        _phase = _GamePhase.result;
      } else {
        _currentIndex++;
      }
    });
    _animateTransition();
  }

  void _animateTransition() {
    _slideController.reset();
    _slideController.forward();
  }

  int get _intimacyScore =>
      (_correctCount / _questions.length * 100).round();

  String get _intimacyLabel {
    final score = _intimacyScore;
    if (score >= 90) return 'Soul Mates 💍';
    if (score >= 75) return 'Pasangan Serasi 💞';
    if (score >= 60) return 'Cukup Saling Kenal 🌸';
    if (score >= 40) return 'Masih Perlu Eksplorasi 🌱';
    return 'Baru Kenalan Nih! 😄';
  }

  String get _encouragement =>
      _encouragements[_correctCount % _encouragements.length];

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
                            'Know Your Partner 🧠',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            _phase == _GamePhase.answer
                                ? 'Fase 1: $p1Name menjawab'
                                : _phase == _GamePhase.verify
                                    ? 'Fase 2: $p2Name verifikasi'
                                    : 'Hasil',
                            style: TextStyle(fontSize: 12, color: mutedColor),
                          ),
                        ],
                      ),
                    ),
                    if (_phase != _GamePhase.result)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / ${_questions.length}',
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

              // Phase indicator
              if (_phase != _GamePhase.result)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _PhaseChip(
                            label: 'Fase 1',
                            isActive: _phase == _GamePhase.answer,
                            isDone: _phase != _GamePhase.answer,
                            isAfterDark: isAfterDark,
                          ),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: _phase == _GamePhase.verify
                                  ? primaryColor
                                  : primaryColor.withValues(alpha: 0.2),
                            ),
                          ),
                          _PhaseChip(
                            label: 'Fase 2',
                            isActive: _phase == _GamePhase.verify,
                            isDone: false,
                            isAfterDark: isAfterDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (_currentIndex + 1) / _questions.length,
                          backgroundColor: primaryColor.withValues(alpha: 0.15),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              Expanded(
                child: _phase == _GamePhase.result
                    ? _ResultView(
                        intimacyScore: _intimacyScore,
                        intimacyLabel: _intimacyLabel,
                        encouragement: _encouragement,
                        correctCount: _correctCount,
                        totalXp: _totalXp,
                        questions: _questions,
                        answers: _answers,
                        verifications: _verifications,
                        isAfterDark: isAfterDark,
                        onDone: () => Navigator.of(context).pop(),
                      )
                    : SlideTransition(
                        position: _slideAnim,
                        child: _phase == _GamePhase.answer
                            ? _AnswerPhaseView(
                                question: _questions[_currentIndex],
                                questionIndex: _currentIndex,
                                playerName: p1Name,
                                partnerName: p2Name,
                                textController: _textController,
                                onSubmit: _submitAnswer,
                                isAfterDark: isAfterDark,
                              )
                            : _VerifyPhaseView(
                                question: _questions[_currentIndex],
                                p1Answer: _answers[_currentIndex],
                                questionIndex: _currentIndex,
                                p1Name: p1Name,
                                p2Name: p2Name,
                                onVerify: _submitVerification,
                                isAfterDark: isAfterDark,
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
//  Phase Views
// ─────────────────────────────────────────────

class _AnswerPhaseView extends StatelessWidget {
  final String question;
  final int questionIndex;
  final String playerName;
  final String partnerName;
  final TextEditingController textController;
  final VoidCallback onSubmit;
  final bool isAfterDark;

  const _AnswerPhaseView({
    required this.question,
    required this.questionIndex,
    required this.playerName,
    required this.partnerName,
    required this.textController,
    required this.onSubmit,
    required this.isAfterDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor = isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final primaryColor = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final cardBg = isAfterDark ? AppColors.darkCard : AppColors.normalCard;
    final borderColor = isAfterDark ? AppColors.darkBorder : AppColors.normalBorder;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Instruction card
          CustomCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '🧠',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$playerName menjawab pertanyaan tentang $partnerName. $partnerName jangan melihat! 🙈',
                    style: TextStyle(fontSize: 13, color: mutedColor, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Question card
          CustomCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Pertanyaan ${questionIndex + 1}',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  question,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Answer input
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: textController,
              style: TextStyle(color: textColor, fontSize: 15),
              maxLines: 3,
              minLines: 2,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmit(),
              decoration: InputDecoration(
                hintText: 'Tulis jawabanmu di sini...',
                hintStyle: TextStyle(color: mutedColor.withValues(alpha: 0.6)),
                contentPadding: const EdgeInsets.all(16),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: GradientButton(
              text: questionIndex + 1 >= _questions.length
                  ? 'Selesai Menjawab ✓'
                  : 'Pertanyaan Berikutnya →',
              onPressed: onSubmit,
              icon: questionIndex + 1 >= _questions.length
                  ? Icons.check_rounded
                  : null,
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _VerifyPhaseView extends StatelessWidget {
  final String question;
  final String p1Answer;
  final int questionIndex;
  final String p1Name;
  final String p2Name;
  final void Function(bool) onVerify;
  final bool isAfterDark;

  const _VerifyPhaseView({
    required this.question,
    required this.p1Answer,
    required this.questionIndex,
    required this.p1Name,
    required this.p2Name,
    required this.onVerify,
    required this.isAfterDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor = isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final primaryColor = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Instruction
          CustomCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('✅', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$p2Name, verifikasi jawaban $p1Name. Apakah benar?',
                    style: TextStyle(fontSize: 13, color: mutedColor, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Question
          CustomCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Pertanyaan ${questionIndex + 1}',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  question,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Answer card
          CustomCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jawaban $p1Name:',
                  style: TextStyle(
                    fontSize: 12,
                    color: mutedColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    p1Answer.isEmpty ? '(tidak dijawab)' : p1Answer,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      fontStyle: p1Answer.isEmpty ? FontStyle.italic : FontStyle.normal,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Verify buttons
          Text(
            '$p2Name, apakah jawaban ini benar?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: mutedColor,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onVerify(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.loveRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.loveRed.withValues(alpha: 0.4)),
                    ),
                    child: const Column(
                      children: [
                        Text('❌', style: TextStyle(fontSize: 28)),
                        SizedBox(height: 6),
                        Text(
                          'Salah',
                          style: TextStyle(
                            color: AppColors.loveRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => onVerify(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                    ),
                    child: const Column(
                      children: [
                        Text('✅', style: TextStyle(fontSize: 28)),
                        SizedBox(height: 6),
                        Text(
                          'Benar',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Result View
// ─────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  final int intimacyScore;
  final String intimacyLabel;
  final String encouragement;
  final int correctCount;
  final int totalXp;
  final List<String> questions;
  final List<String> answers;
  final List<bool?> verifications;
  final bool isAfterDark;
  final VoidCallback onDone;

  const _ResultView({
    required this.intimacyScore,
    required this.intimacyLabel,
    required this.encouragement,
    required this.correctCount,
    required this.totalXp,
    required this.questions,
    required this.answers,
    required this.verifications,
    required this.isAfterDark,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor = isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final primaryColor = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Score card
          CustomCard(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Text('🧠', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  intimacyLabel,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                // Score meter
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: intimacyScore / 100,
                        strokeWidth: 10,
                        backgroundColor: primaryColor.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$intimacyScore%',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          'Intimacy',
                          style:
                              TextStyle(fontSize: 12, color: mutedColor),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  encouragement,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatChip(
                      label: 'Benar',
                      value: '$correctCount',
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      label: 'Salah',
                      value: '${questions.length - correctCount}',
                      color: AppColors.loveRed,
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      label: 'XP',
                      value: '+$totalXp',
                      color: AppColors.gold,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Answer review
          Text(
            'Rekap Jawaban',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(height: 12),

          ...List.generate(questions.length, (i) {
            final isCorrect = verifications[i] ?? false;
            final color = isCorrect ? AppColors.success : AppColors.loveRed;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CustomCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCorrect ? '✅' : '❌',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            questions[i],
                            style: TextStyle(
                              fontSize: 12,
                              color: mutedColor,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            answers[i].isEmpty ? '(tidak dijawab)' : answers[i],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: color,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: GradientButton(
              text: 'Selesai 🎉',
              onPressed: onDone,
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Helper Widgets
// ─────────────────────────────────────────────

class _PhaseChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDone;
  final bool isAfterDark;

  const _PhaseChip({
    required this.label,
    required this.isActive,
    required this.isDone,
    required this.isAfterDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final mutedColor = isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;

    Color bgColor;
    Color textColor;
    if (isActive) {
      bgColor = primaryColor;
      textColor = Colors.white;
    } else if (isDone) {
      bgColor = AppColors.success;
      textColor = Colors.white;
    } else {
      bgColor = mutedColor.withValues(alpha: 0.15);
      textColor = mutedColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isDone ? '✓ $label' : label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}