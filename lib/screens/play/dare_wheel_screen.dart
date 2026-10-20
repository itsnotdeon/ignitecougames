import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/bond_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

enum DareLevel { manis, lucu, berani, intim }

extension DareLevelMeta on DareLevel {
  String get label {
    switch (this) {
      case DareLevel.manis:
        return 'Manis 🍯';
      case DareLevel.lucu:
        return 'Lucu 😂';
      case DareLevel.berani:
        return 'Berani 🔥';
      case DareLevel.intim:
        return 'Intim 💋';
    }
  }

  Color get color {
    switch (this) {
      case DareLevel.manis:
        return const Color(0xFFE26D7D); // pink
      case DareLevel.lucu:
        return const Color(0xFFD97706); // yellow-amber
      case DareLevel.berani:
        return const Color(0xFFE11D48); // orange-red
      case DareLevel.intim:
        return const Color(0xFF6B21A8); // dark purple
    }
  }

  Color get lightColor {
    switch (this) {
      case DareLevel.manis:
        return const Color(0xFFFFB3C1);
      case DareLevel.lucu:
        return const Color(0xFFFFD966);
      case DareLevel.berani:
        return const Color(0xFFFF8A65);
      case DareLevel.intim:
        return const Color(0xFFB57BEE);
    }
  }
}

const Map<DareLevel, List<String>> _dareMap = {
  DareLevel.manis: [
    'Kecup kening pasanganmu 😊',
    'Ucapkan 3 hal yang kamu sayangi darinya',
    'Peluk dari belakang selama 30 detik',
    'Buat satu pujian tulus untuknya sekarang',
    'Bisikkan kata "aku sayang kamu" di telinganya',
  ],
  DareLevel.lucu: [
    'Lakukan impression karakter kartun favorit selama 30 detik',
    'Nyanyi lagu anak-anak dengan suara paling dramatis',
    'Buat rap dadakan tentang pasanganmu',
    'Gambar potret pasanganmu dengan mata tertutup',
    'Ceritakan mimpi paling anehmu belakangan ini',
  ],
  DareLevel.berani: [
    'Ungkapkan 1 rahasia kecil yang belum pernah kamu ceritakan',
    'Telepon anggota keluarga dan bilang hal paling manis tentang pasanganmu',
    'Tulis surat cinta 5 kalimat dan bacakan keras-keras',
    'Buat status sosmed tentang hal yang paling kamu kagumi darinya',
    'Jawab: apa hal yang paling ingin kamu ubah dari dirimu untuk hubungan ini?',
  ],
  DareLevel.intim: [
    'Kecup leher pasanganmu perlahan selama 15 detik',
    'Bisikkan 3 hal paling intim yang kamu inginkan',
    'Pijat punggung bawah pasanganmu dengan lembut',
    'Tatap matanya dan ungkapkan fantasi romantismu',
    'Berikan sentuhan paling lembut di bibir pasanganmu',
  ],
};

// ---------------------------------------------------------------------------
// Wheel Painter
// ---------------------------------------------------------------------------

class _WheelPainter extends CustomPainter {
  final List<DareLevel> segments;
  final double rotationAngle;

  const _WheelPainter({
    required this.segments,
    required this.rotationAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = (2 * pi) / segments.length;

    for (int i = 0; i < segments.length; i++) {
      final startAngle = rotationAngle + i * segmentAngle - pi / 2;
      final paint = Paint()
        ..color = segments[i].color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // Segment border
      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        borderPaint,
      );

      // Label
      final labelAngle = startAngle + segmentAngle / 2;
      final labelRadius = radius * 0.62;
      final labelX = center.dx + labelRadius * cos(labelAngle);
      final labelY = center.dy + labelRadius * sin(labelAngle);

      canvas.save();
      canvas.translate(labelX, labelY);
      canvas.rotate(labelAngle + pi / 2);

      final textPainter = TextPainter(
        text: TextSpan(
          text: segments[i].label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(color: Colors.black38, blurRadius: 4),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Center circle
    canvas.drawCircle(
      center,
      radius * 0.13,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      center,
      radius * 0.09,
      Paint()..color = Colors.grey.shade300,
    );
  }

  @override
  bool shouldRepaint(_WheelPainter oldDelegate) =>
      oldDelegate.rotationAngle != rotationAngle ||
      oldDelegate.segments != segments;
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class DareWheelScreen extends StatefulWidget {
  const DareWheelScreen({super.key});

  @override
  State<DareWheelScreen> createState() => _DareWheelScreenState();
}

class _DareWheelScreenState extends State<DareWheelScreen>
    with SingleTickerProviderStateMixin {
  static const int _xpReward = 20;

  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  double _currentAngle = 0;
  double _targetAngle = 0;
  bool _isSpinning = false;
  DareLevel? _landedLevel;
  String? _currentDare;

  List<DareLevel> _segments = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _spinAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOut,
    );
    _spinController.addListener(() {
      setState(() {
        _currentAngle =
            _targetAngle * _spinAnimation.value;
      });
    });
    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isSpinning = false);
        _onSpinEnd();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buildSegments();
  }

  void _buildSegments() {
    final isAfterDark = context.read<AppProvider>().isAfterDark;
    _segments = [
      DareLevel.manis,
      DareLevel.lucu,
      DareLevel.berani,
      if (isAfterDark) DareLevel.intim,
    ];
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;
    _buildSegments();

    // Random full rotations (5-10) + random land angle
    final extraSpins = (5 + _random.nextInt(6)) * 2 * pi;
    final landAngle = _random.nextDouble() * 2 * pi;
    _targetAngle = _currentAngle + extraSpins + landAngle;

    setState(() {
      _isSpinning = true;
      _landedLevel = null;
    });

    _spinController.forward(from: 0);
  }

  void _onSpinEnd() {
    final segmentAngle = (2 * pi) / _segments.length;
    // Normalize final angle
    final normalizedAngle = _targetAngle % (2 * pi);
    // The pointer is at top (12 o'clock = -pi/2). Determine which segment is at top.
    // Top pointer hits the segment whose midpoint is at angle 0 (top), accounting for rotation.
    final pointerAngle = ((-normalizedAngle % (2 * pi)) + 2 * pi) % (2 * pi);
    final segmentIndex =
        (pointerAngle / segmentAngle).floor() % _segments.length;
    final landed = _segments[segmentIndex];

    final dares = List<String>.from(_dareMap[landed]!);
    dares.shuffle(_random);

    setState(() {
      _landedLevel = landed;
      _currentDare = dares.first;
    });

    _showDareBottomSheet(landed, dares.first);
  }

  void _showDareBottomSheet(DareLevel level, String dare) {
    final isAfterDark = context.read<AppProvider>().isAfterDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _DareBottomSheet(
          level: level,
          dare: dare,
          isAfterDark: isAfterDark,
          xpReward: _xpReward,
          onComplete: () {
            Navigator.pop(context);
            context.read<BondProvider>().addXp(_xpReward);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 Dare selesai! +$_xpReward XP'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          onSkip: () => Navigator.pop(context),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;
    final primaryColor =
        isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final textColor =
        isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor =
        isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;

    final segments = _segments.isEmpty
        ? [DareLevel.manis, DareLevel.lucu, DareLevel.berani]
        : _segments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dare Wheel 🎡'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Header
              Text(
                'Putar Roda Keberanian!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isAfterDark
                    ? '4 level: Manis · Lucu · Berani · Intim 💋'
                    : '3 level: Manis · Lucu · Berani 🔥',
                style: TextStyle(fontSize: 13, color: mutedColor),
              ),

              const SizedBox(height: 24),

              // Wheel
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pointer
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        color: primaryColor,
                        size: 36,
                      ),
                      const SizedBox(height: 2),

                      // Wheel container
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: AnimatedBuilder(
                          animation: _spinAnimation,
                          builder: (_, __) => CustomPaint(
                            painter: _WheelPainter(
                              segments: segments,
                              rotationAngle: _currentAngle,
                            ),
                            size: const Size(280, 280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Landed level display
              if (_landedLevel != null && !_isSpinning)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        _landedLevel!.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _landedLevel!.color.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    'Mendarat di: ${_landedLevel!.label}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _landedLevel!.color,
                    ),
                  ),
                ),

              // Spin button
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: _isSpinning ? 'Memutar...' : 'Putar Roda 🎡',
                  icon: _isSpinning
                      ? Icons.hourglass_top_rounded
                      : Icons.rotate_right_rounded,
                  onPressed: _isSpinning ? () {} : _spinWheel,
                ),
              ),

              const SizedBox(height: 12),

              if (_landedLevel != null && !_isSpinning)
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    text: 'Lihat Dare Lagi',
                    icon: Icons.visibility_rounded,
                    isSecondary: true,
                    onPressed: () {
                      if (_landedLevel != null && _currentDare != null) {
                        _showDareBottomSheet(_landedLevel!, _currentDare!);
                      }
                    },
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

// ---------------------------------------------------------------------------
// Bottom Sheet
// ---------------------------------------------------------------------------

class _DareBottomSheet extends StatelessWidget {
  final DareLevel level;
  final String dare;
  final bool isAfterDark;
  final int xpReward;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const _DareBottomSheet({
    required this.level,
    required this.dare,
    required this.isAfterDark,
    required this.xpReward,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isAfterDark ? AppColors.darkSurface : AppColors.normalSurface;
    final textColor =
        isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor =
        isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: level.color.withValues(alpha: 0.25),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: level.color.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),

          // Level badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [level.color, level.lightColor],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              level.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Dare text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: level.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: level.color.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              dare,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: textColor,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Selesaikan dare ini untuk mendapat +$xpReward XP ⭐',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: mutedColor),
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            child: GradientButton(
              text: 'Selesai! Ambil +$xpReward XP 🎉',
              icon: Icons.check_circle_rounded,
              onPressed: onComplete,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              text: 'Lewati',
              icon: Icons.skip_next_rounded,
              isSecondary: true,
              onPressed: onSkip,
            ),
          ),
        ],
      ),
    );
  }
}