import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/app_provider.dart';
import '../../providers/bond_provider.dart';
import '../../providers/couple_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/gradient_button.dart';

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

const Map<String, List<String>> _dreamCategories = {
  '✈️ Travel Dreams': [
    'Negara mana yang paling ingin kalian kunjungi?',
    'Mode perjalanan favorit kalian: backpacker atau mewah?',
    'Satu destinasi bucket list yang WAJIB sebelum usia 40?',
  ],
  '🏠 Home Dreams': [
    'Kota mana tempat kalian ingin menetap?',
    'Rumah impian: minimalis modern atau klasik hangat?',
    'Satu hal wajib ada di rumah impian kalian?',
  ],
  '👨‍👩‍👧 Family Dreams': [
    'Berapa anak yang kalian impikan?',
    'Nama apa yang kalian suka untuk anak pertama?',
    'Nilai keluarga paling penting yang ingin kalian tanamkan?',
  ],
  '💼 Career & Lifestyle': [
    'Pekerjaan impian masing-masing 5 tahun ke depan?',
    'Side business apa yang ingin kalian bangun bersama?',
    'Definisi "sukses" menurut kalian berdua?',
  ],
  '🌙 Relationship Goals': [
    'Tradisi pasangan apa yang ingin kalian mulai?',
    'Satu hal yang ingin kalian lakukan setiap ulang tahun bersama?',
    'Kenangan apa yang ingin kalian ceritakan ke cucu suatu saat?',
  ],
};

const String _prefsKey = 'dream_planning_data';

// ---------------------------------------------------------------------------
// Main Screen
// ---------------------------------------------------------------------------

class DreamPlanningScreen extends StatefulWidget {
  const DreamPlanningScreen({super.key});

  @override
  State<DreamPlanningScreen> createState() => _DreamPlanningScreenState();
}

class _DreamPlanningScreenState extends State<DreamPlanningScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  /// category -> question -> [answer1, answer2]
  late final Map<String, Map<String, List<String>>> _answers;

  /// Flat map of TextEditingControllers keyed by "$category|$question|$idx"
  final Map<String, TextEditingController> _controllers = {};

  bool _loading = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: _dreamCategories.length, vsync: this);

    // Initialise answer structure
    _answers = {
      for (final cat in _dreamCategories.keys)
        cat: {
          for (final q in _dreamCategories[cat]!) q: ['', ''],
        },
    };

    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  String _controllerKey(String cat, String question, int idx) =>
      '$cat|$question|$idx';

  TextEditingController _controllerFor(
      String cat, String question, int idx) {
    final key = _controllerKey(cat, question, idx);
    return _controllers.putIfAbsent(
      key,
      () {
        final text = _answers[cat]?[question]?[idx] ?? '';
        final ctrl = TextEditingController(text: text);
        ctrl.addListener(() {
          _answers[cat]![question]![idx] = ctrl.text;
          if (mounted) setState(() => _saved = false);
        });
        return ctrl;
      },
    );
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final decoded =
            jsonDecode(raw) as Map<String, dynamic>;
        for (final catEntry in decoded.entries) {
          final cat = catEntry.key;
          if (!_answers.containsKey(cat)) continue;
          final questions = catEntry.value as Map<String, dynamic>;
          for (final qEntry in questions.entries) {
            final q = qEntry.key;
            if (!_answers[cat]!.containsKey(q)) continue;
            final list = (qEntry.value as List<dynamic>)
                .map((e) => e as String)
                .toList();
            _answers[cat]![q] = list.length >= 2
                ? [list[0], list[1]]
                : ['', ''];
          }
        }
      }
    } catch (_) {
      // Ignore; start fresh
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_answers));
    if (mounted) setState(() => _saved = true);
  }

  // ── Computed helpers ──────────────────────────────────────────────────────

  int _filledCount(String cat) {
    int count = 0;
    for (final answers in _answers[cat]!.values) {
      if (answers[0].trim().isNotEmpty && answers[1].trim().isNotEmpty) {
        count++;
      }
    }
    return count;
  }

  int _totalQuestions(String cat) => _dreamCategories[cat]!.length;

  bool get _allFilled {
    for (final cat in _dreamCategories.keys) {
      if (_filledCount(cat) < _totalQuestions(cat)) return false;
    }
    return true;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _completeDreams(BuildContext context) async {
    await _saveData();
    if (!context.mounted) return;
    context.read<BondProvider>().addXp(50);
    context.read<BondProvider>().unlockAchievement('dream_planner');
    _showCompletionSnackbar(context);
    await _navigateToSummary(context);
  }

  void _showCompletionSnackbar(BuildContext context) {
    final isAfterDark = context.read<AppProvider>().isAfterDark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🌟', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              '+50 XP — Dream Planner unlocked!',
              style: TextStyle(
                color: isAfterDark
                    ? AppColors.darkText
                    : AppColors.normalText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor:
            isAfterDark ? AppColors.darkCard : AppColors.normalCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _navigateToSummary(BuildContext context) async {
    final coupleProfile =
        context.read<CoupleProvider>().profile;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _DreamSummaryScreen(
          answers: Map<String, Map<String, List<String>>>.from(
            _answers.map(
              (cat, qs) => MapEntry(
                cat,
                Map<String, List<String>>.from(qs),
              ),
            ),
          ),
          partner1: coupleProfile.partner1,
          partner2: coupleProfile.partner2,
          emoji1: coupleProfile.emoji1,
          emoji2: coupleProfile.emoji2,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;
    final coupleProfile = context.watch<CoupleProvider>().profile;
    final partner1 = coupleProfile.partner1;
    final partner2 = coupleProfile.partner2;

    final bgTop =
        isAfterDark ? AppColors.darkBgTop : AppColors.normalBgTop;
    final bgBottom =
        isAfterDark ? AppColors.darkBgBottom : AppColors.normalBgBottom;
    final textColor =
        isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor =
        isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final primary =
        isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;

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
              _buildHeader(textColor, mutedColor, primary),
              if (_loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                _buildTabBar(isAfterDark, textColor, primary),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _dreamCategories.keys.map((cat) {
                      return _buildCategoryTab(
                        context,
                        cat,
                        partner1,
                        partner2,
                        isAfterDark,
                        textColor,
                        mutedColor,
                        primary,
                      );
                    }).toList(),
                  ),
                ),
                _buildBottomBar(
                    context, isAfterDark, textColor, mutedColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      Color textColor, Color mutedColor, Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: textColor, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dream Planning Together',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bangun masa depan kalian bersama ✨',
                  style:
                      TextStyle(color: mutedColor, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded,
                    color: primary, size: 14),
                const SizedBox(width: 4),
                Text('+50 XP',
                    style: TextStyle(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(
      bool isAfterDark, Color textColor, Color primary) {
    final bgSurface =
        isAfterDark ? AppColors.darkSurface : AppColors.normalSurface;
    final border =
        isAfterDark ? AppColors.darkBorder : AppColors.normalBorder;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border.withValues(alpha: 0.4)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: isAfterDark
                ? [AppColors.darkPrimary, AppColors.darkSecondary]
                : [AppColors.normalPrimary, AppColors.normalSecondary],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor:
            isAfterDark ? AppColors.darkText : Colors.white,
        unselectedLabelColor: textColor.withValues(alpha: 0.6),
        labelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        padding: const EdgeInsets.all(4),
        tabs: _dreamCategories.keys.map((cat) {
          final filled = _filledCount(cat);
          final total = _totalQuestions(cat);
          return Tab(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat.split(' ').first), // emoji
                  const SizedBox(width: 6),
                  Text(cat.split(' ').skip(1).join(' ')),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: filled == total
                          ? AppColors.success.withValues(alpha: 0.3)
                          : primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$filled/$total',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: filled == total
                            ? AppColors.success
                            : primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryTab(
    BuildContext context,
    String cat,
    String partner1,
    String partner2,
    bool isAfterDark,
    Color textColor,
    Color mutedColor,
    Color primary,
  ) {
    final questions = _dreamCategories[cat]!;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: questions.length,
      itemBuilder: (_, i) {
        final q = questions[i];
        return _buildQuestionCard(
          cat,
          q,
          i + 1,
          partner1,
          partner2,
          isAfterDark,
          textColor,
          mutedColor,
          primary,
        );
      },
    );
  }

  Widget _buildQuestionCard(
    String cat,
    String question,
    int number,
    String partner1,
    String partner2,
    bool isAfterDark,
    Color textColor,
    Color mutedColor,
    Color primary,
  ) {
    final ctrl1 = _controllerFor(cat, question, 0);
    final ctrl2 = _controllerFor(cat, question, 1);

    final a1 = _answers[cat]![question]![0].trim();
    final a2 = _answers[cat]![question]![1].trim();
    final bothFilled = a1.isNotEmpty && a2.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isAfterDark
                            ? [
                                AppColors.darkPrimary,
                                AppColors.darkSecondary
                              ]
                            : [
                                AppColors.normalPrimary,
                                AppColors.normalSecondary
                              ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (bothFilled)
                    Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 20),
                ],
              ),
              const SizedBox(height: 14),
              _buildAnswerField(
                ctrl1,
                partner1,
                isAfterDark,
                textColor,
                mutedColor,
                primary,
                index: 0,
              ),
              const SizedBox(height: 10),
              _buildAnswerField(
                ctrl2,
                partner2,
                isAfterDark,
                textColor,
                mutedColor,
                primary,
                index: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerField(
    TextEditingController controller,
    String partnerName,
    bool isAfterDark,
    Color textColor,
    Color mutedColor,
    Color primary,
    {required int index}
  ) {
    final borderColor =
        isAfterDark ? AppColors.darkBorder : AppColors.normalBorder;
    final surfaceColor =
        isAfterDark ? AppColors.darkSurface : AppColors.normalSurface;

    final partnerColor = index == 0
        ? (isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary)
        : (isAfterDark
            ? AppColors.darkSecondary
            : AppColors.normalSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: partnerColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                partnerName,
                style: TextStyle(
                  color: partnerColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: TextStyle(color: textColor, fontSize: 14),
          maxLines: 2,
          minLines: 1,
          cursorColor: primary,
          decoration: InputDecoration(
            hintText: 'Jawaban ${partnerName}...',
            hintStyle:
                TextStyle(color: mutedColor.withValues(alpha: 0.6), fontSize: 13),
            filled: true,
            fillColor: surfaceColor,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: borderColor.withValues(alpha: 0.4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: borderColor.withValues(alpha: 0.4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    bool isAfterDark,
    Color textColor,
    Color mutedColor,
  ) {
    final bgSurface =
        isAfterDark ? AppColors.darkSurface : AppColors.normalSurface;
    final border =
        isAfterDark ? AppColors.darkBorder : AppColors.normalBorder;

    int totalFilled = 0;
    int totalAll = 0;
    for (final cat in _dreamCategories.keys) {
      totalFilled += _filledCount(cat);
      totalAll += _totalQuestions(cat);
    }

    final progress = totalAll > 0 ? totalFilled / totalAll : 0.0;
    final primary =
        isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final secondary =
        isAfterDark ? AppColors.darkSecondary : AppColors.normalSecondary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: bgSurface,
        border: Border(
          top: BorderSide(color: border.withValues(alpha: 0.4)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded,
                  color: AppColors.loveRed, size: 16),
              const SizedBox(width: 6),
              Text(
                '$totalFilled/$totalAll pertanyaan dijawab',
                style: TextStyle(
                    color: mutedColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              if (_saved)
                Row(
                  children: [
                    Icon(Icons.cloud_done_rounded,
                        color: AppColors.success, size: 14),
                    const SizedBox(width: 4),
                    Text('Tersimpan',
                        style: TextStyle(
                            color: AppColors.success, fontSize: 12)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: primary.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.lerp(primary, secondary, progress) ?? primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saveData,
                  icon: const Icon(Icons.save_outlined, size: 16),
                  label: const Text('Simpan'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GradientButton(
                  onPressed:
                      _allFilled ? () => _completeDreams(context) : null,
                  text: _allFilled
                      ? 'Simpan & Selesaikan 🌟'
                      : 'Isi semua dulu...',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary Screen
// ---------------------------------------------------------------------------

class _DreamSummaryScreen extends StatelessWidget {
  final Map<String, Map<String, List<String>>> answers;
  final String partner1;
  final String partner2;
  final String emoji1;
  final String emoji2;

  const _DreamSummaryScreen({
    required this.answers,
    required this.partner1,
    required this.partner2,
    required this.emoji1,
    required this.emoji2,
  });

  @override
  Widget build(BuildContext context) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;

    final bgTop =
        isAfterDark ? AppColors.darkBgTop : AppColors.normalBgTop;
    final bgBottom =
        isAfterDark ? AppColors.darkBgBottom : AppColors.normalBgBottom;
    final textColor =
        isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor =
        isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final primary =
        isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final secondary =
        isAfterDark ? AppColors.darkSecondary : AppColors.normalSecondary;

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
              _buildSummaryHeader(context, textColor, mutedColor,
                  primary, secondary, isAfterDark),
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    for (final catEntry in answers.entries)
                      _buildCategorySection(
                        catEntry.key,
                        catEntry.value,
                        isAfterDark,
                        textColor,
                        mutedColor,
                        primary,
                        secondary,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(
    BuildContext context,
    Color textColor,
    Color mutedColor,
    Color primary,
    Color secondary,
    bool isAfterDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: textColor, size: 20),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary.withValues(alpha: 0.2),
                  secondary.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  '$emoji1  💕  $emoji2',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  'Impian Bersama Kalian',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$partner1 & $partner2',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.gold, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Dream Planner Achievement Unlocked!',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    String cat,
    Map<String, List<String>> questions,
    bool isAfterDark,
    Color textColor,
    Color mutedColor,
    Color primary,
    Color secondary,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [primary, secondary]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cat,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...questions.entries.map((qEntry) => _buildSummaryQuestionCard(
                qEntry.key,
                qEntry.value,
                isAfterDark,
                textColor,
                mutedColor,
                primary,
                secondary,
              )),
        ],
      ),
    );
  }

  Widget _buildSummaryQuestionCard(
    String question,
    List<String> ans,
    bool isAfterDark,
    Color textColor,
    Color mutedColor,
    Color primary,
    Color secondary,
  ) {
    final a1 = ans.isNotEmpty ? ans[0] : '';
    final a2 = ans.length > 1 ? ans[1] : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(