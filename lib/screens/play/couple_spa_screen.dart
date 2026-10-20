import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/bond_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_card.dart';

enum _SpaView { selection, stepList, activeStep, completed }

class SpaStep {
  final String name;
  final int durationMinutes;
  final String instruction;

  const SpaStep({
    required this.name,
    required this.durationMinutes,
    required this.instruction,
  });

  int get durationSeconds => durationMinutes * 60;
}

class SpaRoutine {
  final String name;
  final bool afterDarkOnly;
  final List<SpaStep> steps;

  const SpaRoutine({
    required this.name,
    required this.afterDarkOnly,
    required this.steps,
  });

  int get totalMinutes =>
      steps.fold(0, (sum, step) => sum + step.durationMinutes);
}

const List<SpaRoutine> _allRoutines = [
  SpaRoutine(
    name: 'Romantic Evening Spa 🌹',
    afterDarkOnly: false,
    steps: [
      SpaStep(
        name: '🕯️ Siapkan Suasana',
        durationMinutes: 3,
        instruction:
            'Redupkan lampu, nyalakan lilin aromaterapi jika ada, putar musik instrumental lembut. Pastikan ruangan hangat dan nyaman untuk kalian berdua.',
      ),
      SpaStep(
        name: '🤲 Warm Hand Ritual',
        durationMinutes: 5,
        instruction:
            'Rendam tangan kalian dalam air hangat selama 2 menit. Kemudian saling melembapkan tangan pasangan dengan losion. Pijat setiap jari dengan penuh kasih.',
      ),
      SpaStep(
        name: '💆 Shoulder Release',
        durationMinutes: 7,
        instruction:
            'Bergantian: duduk di belakang pasangan, pijat pundak dan lehernya dengan ibu jari dalam gerakan melingkar. Tanyakan tekanan yang diinginkan.',
      ),
      SpaStep(
        name: '😌 Face Massage',
        durationMinutes: 5,
        instruction:
            'Dengan ujung jari bersih, pijat pelipis pasanganmu dengan gerakan melingkar lembut. Lanjutkan ke dahi dan tulang pipi. Selesaikan dengan usapan lembut dari dahi ke pipi.',
      ),
      SpaStep(
        name: '🫂 Closing Hug',
        durationMinutes: 3,
        instruction:
            'Duduk berhadapan, peluk satu sama lain erat-erat. Tarik nafas dalam bersama 3 kali. Ucapkan terima kasih untuk sesi ini.',
      ),
    ],
  ),
  SpaRoutine(
    name: 'Deep Relax Session 🌿',
    afterDarkOnly: false,
    steps: [
      SpaStep(
        name: '🌿 Aromaterapi',
        durationMinutes: 2,
        instruction:
            'Teteskan 3 tetes essential oil lavender di tangan dan hirup bersama.',
      ),
      SpaStep(
        name: '🧘 Mindful Breathing',
        durationMinutes: 5,
        instruction:
            'Duduk berhadapan, tangan bersentuhan. Tarik nafas bersama selama 4 hitungan, tahan 4, hembuskan 4.',
      ),
      SpaStep(
        name: '👣 Foot Ritual',
        durationMinutes: 10,
        instruction:
            'Rendam kaki dalam air hangat. Bergantian memijat telapak kaki pasangan dengan penuh perhatian.',
      ),
      SpaStep(
        name: '💤 Savasana Berdua',
        durationMinutes: 8,
        instruction:
            'Berbaring berdampingan, tidak berbicara, hanya merasakan kehadiran satu sama lain.',
      ),
    ],
  ),
  SpaRoutine(
    name: 'After Dark Ritual 🌙',
    afterDarkOnly: true,
    steps: [
      SpaStep(
        name: '🌙 Set the Mood',
        durationMinutes: 3,
        instruction:
            'Redupkan semua lampu, gunakan hanya cahaya lilin. Pilih playlist musik yang intim dan pelan.',
      ),
      SpaStep(
        name: '💋 Lip Care',
        durationMinutes: 3,
        instruction:
            'Oleskan lip balm di bibir pasanganmu dengan ujung jari. Lakukan dengan penuh perhatian dan perlahan.',
      ),
      SpaStep(
        name: '🌸 Back Trace',
        durationMinutes: 7,
        instruction:
            'Dengan ujung jari, gambar pola lembut di punggung pasangan — bisa huruf, bentuk, atau perasaanmu.',
      ),
      SpaStep(
        name: '💑 Intimacy Moment',
        durationMinutes: 5,
        instruction:
            'Berbaring berdampingan, wajah berhadapan. Saling menatap dan berbagi 3 hal yang membuat kalian semakin jatuh cinta hari ini.',
      ),
    ],
  ),
];

class CoupleSpaScreen extends StatefulWidget {
  const CoupleSpaScreen({super.key});

  @override
  State<CoupleSpaScreen> createState() => _CoupleSpaScreenState();
}

class _CoupleSpaScreenState extends State<CoupleSpaScreen>
    with TickerProviderStateMixin {
  _SpaView _currentView = _SpaView.selection;

  SpaRoutine? _selectedRoutine;
  int _currentStepIndex = 0;

  int _remainingSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _selectRoutine(SpaRoutine routine) {
    setState(() {
      _selectedRoutine = routine;
      _currentView = _SpaView.stepList;
    });
  }

  void _startSession() {
    if (_selectedRoutine == null) return;
    setState(() {
      _currentStepIndex = 0;
      _remainingSeconds = _selectedRoutine!.steps[0].durationSeconds;
      _isRunning = false;
      _currentView = _SpaView.activeStep;
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _timer?.cancel();
          setState(() => _isRunning = false);
        }
      });
    }
  }

  void _nextStep() {
    _timer?.cancel();
    if (_selectedRoutine == null) return;
    final steps = _selectedRoutine!.steps;
    if (_currentStepIndex < steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _remainingSeconds = steps[_currentStepIndex].durationSeconds;
        _isRunning = false;
      });
    } else {
      setState(() {
        _isRunning = false;
        _currentView = _SpaView.completed;
      });
    }
  }

  void _claimXp() {
    context.read<BondProvider>().addXp(40);
    Navigator.of(context).pop();
  }

  void _goBack() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      switch (_currentView) {
        case _SpaView.stepList:
          _currentView = _SpaView.selection;
          break;
        case _SpaView.activeStep:
          _currentView = _SpaView.stepList;
          break;
        case _SpaView.completed:
          _currentView = _SpaView.selection;
          break;
        case _SpaView.selection:
          break;
      }
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

    final bgTop = isAfterDark ? AppColors.darkBgTop : AppColors.normalBgTop;
    final bgBottom =
        isAfterDark ? AppColors.darkBgBottom : AppColors.normalBgBottom;
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final textMuted =
        isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final primaryColor =
        isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final secondaryColor =
        isAfterDark ? AppColors.darkSecondary : AppColors.normalSecondary;
    final cardColor = isAfterDark ? AppColors.darkCard : AppColors.normalCard;
    final surfaceColor =
        isAfterDark ? AppColors.darkSurface : AppColors.normalSurface;
    final borderColor =
        isAfterDark ? AppColors.darkBorder : AppColors.normalBorder;

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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _buildCurrentView(
              isAfterDark: isAfterDark,
              textColor: textColor,
              textMuted: textMuted,
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              cardColor: cardColor,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView({
    required bool isAfterDark,
    required Color textColor,
    required Color textMuted,
    required Color primaryColor,
    required Color secondaryColor,
    required Color cardColor,
    required Color surfaceColor,
    required Color borderColor,
  }) {
    switch (_currentView) {
      case _SpaView.selection:
        return _SelectionView(
          key: const ValueKey('selection'),
          isAfterDark: isAfterDark,
          allRoutines: _allRoutines,
          textColor: textColor,
          textMuted: textMuted,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          cardColor: cardColor,
          borderColor: borderColor,
          onSelectRoutine: _selectRoutine,
          onBack: () => Navigator.of(context).pop(),
        );
      case _SpaView.stepList:
        return _StepListView(
          key: const ValueKey('stepList'),
          routine: _selectedRoutine!,
          isAfterDark: isAfterDark,
          textColor: textColor,
          textMuted: textMuted,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          cardColor: cardColor,
          borderColor: borderColor,
          onStart: _startSession,
          onBack: _goBack,
        );
      case _SpaView.activeStep:
        return _ActiveStepView(
          key: ValueKey('activeStep_$_currentStepIndex'),
          routine: _selectedRoutine!,
          currentStepIndex: _currentStepIndex,
          remainingSeconds: _remainingSeconds,
          isRunning: _isRunning,
          pulseAnimation: _pulseAnimation,
          isAfterDark: isAfterDark,
          textColor: textColor,
          textMuted: textMuted,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          cardColor: cardColor,
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          onToggleTimer: _toggleTimer,
          onNextStep: _nextStep,
          onBack: _goBack,
          formatTime: _formatTime,
        );
      case _SpaView.completed:
        return _CompletedView(
          key: const ValueKey('completed'),
          routine: _selectedRoutine!,
          isAfterDark: isAfterDark,
          textColor: textColor,
          textMuted: textMuted,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          cardColor: cardColor,
          borderColor: borderColor,
          onClaimXp: _claimXp,
        );
    }
  }
}

// ─────────────────────────────────────────────
// SELECTION VIEW
// ─────────────────────────────────────────────

class _SelectionView extends StatelessWidget {
  final bool isAfterDark;
  final List<SpaRoutine> allRoutines;
  final Color textColor;
  final Color textMuted;
  final Color primaryColor;
  final Color secondaryColor;
  final Color cardColor;
  final Color borderColor;
  final ValueChanged<SpaRoutine> onSelectRoutine;
  final VoidCallback onBack;

  const _SelectionView({
    super.key,
    required this.isAfterDark,
    required this.allRoutines,
    required this.textColor,
    required this.textMuted,
    required this.primaryColor,
    required this.secondaryColor,
    required this.cardColor,
    required this.borderColor,
    required this.onSelectRoutine,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final visibleRoutines =
        allRoutines
            .where((r) => !r.afterDarkOnly || isAfterDark)
            .toList();

    return Column(
      children: [
        // App Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: textColor, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Couple Spa Night',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Pilih sesi spa untuk kalian',
                      style: TextStyle(color: textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text('🛁', style: const TextStyle(fontSize: 28)),
            ],
          ),
        ),
        // Hero Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.25),
                  secondaryColor.withValues(alpha: 0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sesi Relaksasi Berdua',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ikuti panduan langkah demi langkah untuk momen spa yang tak terlupakan.',
                        style: TextStyle(color: textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Routine List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: visibleRoutines.length,
            itemBuilder: (context, index) {
              final routine = visibleRoutines[index];
              final bool isSpecial = routine.afterDarkOnly;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GestureDetector(
                  onTap: () => onSelectRoutine(routine),
                  child: CustomCard(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: isSpecial
                            ? LinearGradient(
                                colors: [
                                  AppColors.darkPrimary.withValues(alpha: 0.2),
                                  AppColors.darkSecondary.withValues(
                                    alpha: 0.15,
                                  ),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isSpecial)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.darkPrimary.withValues(
                                        alpha: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      '🌙 After Dark',
                                      style: TextStyle(
                                        color: AppColors.darkPrimary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                Text(
                                  routine.name,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _InfoChip(
                                      icon: Icons.list_rounded,
                                      label:
                                          '${routine.steps.length} langkah',
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    _InfoChip(
                                      icon: Icons.access_time_rounded,
                                      label:
                                          '${routine.totalMinutes} menit',
                                      color: secondaryColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: primaryColor,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// STEP LIST VIEW
// ─────────────────────────────────────────────

class _StepListView extends StatelessWidget {
  final SpaRoutine routine;
  final bool isAfterDark;
  final Color textColor;
  final Color textMuted;
  final Color primaryColor;
  final Color secondaryColor;
  final Color cardColor;
  final Color borderColor;
  final VoidCallback onStart;
  final VoidCallback onBack;

  const _StepListView({
    super.key,
    required this.routine,
    required this.isAfterDark,
    required this.textColor,
    required this.textMuted,
    required this.primaryColor,
    required this.secondaryColor,
    required this.cardColor,
    required this.borderColor,
    required this.onStart,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: textColor, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  routine.name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Summary Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(
                  icon: '📋',
                  value: '${routine.steps.length}',
                  label: 'Langkah',
                  textColor: textColor,
                  textMuted: textMuted,
                ),
                Container(
                    width: 1,
                    height: 30,
                    color: borderColor),
                _SummaryItem(
                  icon: '⏱️',
                  value: '${routine.totalMinutes}',
                  label: 'Menit',
                  textColor: textColor,
                  textMuted: textMuted,
                ),
                Container(
                    width: 1,
                    height: 30,
                    color: borderColor),
                _SummaryItem(
                  icon: '✨',
                  value: '+40',
                  label: 'XP',
                  textColor: textColor,
                  textMuted: textMuted,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Steps list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: routine.steps.length,
            itemBuilder: (context, index) {
              final step = routine.steps[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CustomCard(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.name,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                step.instruction,
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 11.5,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: secondaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${step.durationMinutes}m',
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Start button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: GradientButton(
            onPressed: onStart,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.spa_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Mulai Sesi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ACTIVE STEP VIEW
// ─────────────────────────────────────────────

class _ActiveStepView extends StatelessWidget {
  final SpaRoutine routine;
  final int currentStepIndex;
  final int remainingSeconds;
  final bool isRunning;
  final Animation<double> pulseAnimation;
  final bool isAfterDark;
  final Color textColor;
  final Color textMuted;
  final Color primaryColor;
  final Color secondaryColor;
  final Color cardColor;
  final Color surfaceColor;
  final Color borderColor;
  final VoidCallback onToggleTimer;
  final VoidCallback onNextStep;
  final VoidCallback onBack;
  final String Function(int) formatTime;

  const _ActiveStepView({
    super.key,
    required this.routine,
    required this.currentStepIndex,
    required this.remainingSeconds,
    required this.isRunning,
    required this.pulseAnimation,
    required this.isAfterDark,
    required this.textColor,
    required this.textMuted,
    required this.primaryColor,
    required this.secondaryColor,
    required this.cardColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.onToggleTimer,
    required this.onNextStep,
    required this.onBack,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final step = routine.steps[currentStepIndex];
    final totalSeconds = step.durationSeconds;
    final progress =
        totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;
    final isLastStep = currentStepIndex == routine.steps.length - 1;

    return Column(
      children: [
        // App Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: textColor, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.name,
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Langkah ${currentStepIndex + 1} / ${routine.steps.length}',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
              value: (currentStepIndex + 1) / routine.steps.length,
              minHeight: 5,
              backgroundColor: borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Step name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            step.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Circular Timer
        ScaleTransition(
          scale: isRunning ? pulseAnimation : const AlwaysStoppedAnimation(1.0),
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(