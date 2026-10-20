import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/app_provider.dart';
import '../../providers/bond_provider.dart';
import '../../providers/couple_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_card.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class ContractClause {
  final String id;
  final String sectionTitle;
  final String baseText;
  final List<String> options;
  int selectedOptionIndex;
  final bool hasCustomText;
  final String customLabel;
  String customTextValue;

  ContractClause({
    required this.id,
    required this.sectionTitle,
    required this.baseText,
    required this.options,
    required this.selectedOptionIndex,
    this.hasCustomText = false,
    this.customLabel = '',
    this.customTextValue = '',
  });

  String get renderedText {
    String text = baseText;
    if (options.isNotEmpty && selectedOptionIndex >= 0 && selectedOptionIndex < options.length) {
      text = text.replaceFirst('[X]', options[selectedOptionIndex]);
    }
    if (hasCustomText) {
      final display = customTextValue.trim().isEmpty ? '[${customLabel}]' : customTextValue.trim();
      text = text.replaceFirst('[CUSTOM]', display);
    }
    return text;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sectionTitle': sectionTitle,
        'baseText': baseText,
        'options': options,
        'selectedOptionIndex': selectedOptionIndex,
        'hasCustomText': hasCustomText,
        'customLabel': customLabel,
        'customTextValue': customTextValue,
      };

  factory ContractClause.fromJson(Map<String, dynamic> json) => ContractClause(
        id: json['id'] as String,
        sectionTitle: json['sectionTitle'] as String,
        baseText: json['baseText'] as String,
        options: List<String>.from(json['options'] as List),
        selectedOptionIndex: json['selectedOptionIndex'] as int,
        hasCustomText: json['hasCustomText'] as bool? ?? false,
        customLabel: json['customLabel'] as String? ?? '',
        customTextValue: json['customTextValue'] as String? ?? '',
      );
}

// ---------------------------------------------------------------------------
// Default clauses factory
// ---------------------------------------------------------------------------

List<ContractClause> _buildDefaultClauses() => [
      // 📅 Jadwal & Rutinitas
      ContractClause(
        id: 'jr_1',
        sectionTitle: '📅 Jadwal & Rutinitas',
        baseText: 'Date night wajib setiap [X] malam',
        options: ['Minggu', 'Sabtu', 'Jumat'],
        selectedOptionIndex: 0,
      ),
      ContractClause(
        id: 'jr_2',
        sectionTitle: '📅 Jadwal & Rutinitas',
        baseText: 'Film pilihan bergantian setiap [X]',
        options: ['hari', 'minggu'],
        selectedOptionIndex: 1,
      ),
      ContractClause(
        id: 'jr_3',
        sectionTitle: '📅 Jadwal & Rutinitas',
        baseText: 'Masak bersama minimal [X] seminggu',
        options: ['1x', '2x', '3x'],
        selectedOptionIndex: 0,
      ),
      ContractClause(
        id: 'jr_4',
        sectionTitle: '📅 Jadwal & Rutinitas',
        baseText: 'Morning text wajib setiap hari kerja',
        options: [],
        selectedOptionIndex: -1,
      ),
      // 🍽️ Kuliner & Lifestyle
      ContractClause(
        id: 'kl_1',
        sectionTitle: '🍽️ Kuliner & Lifestyle',
        baseText: 'Yang kalah suit wajib traktir [X]',
        options: ['kopi', 'makan siang', 'dessert'],
        selectedOptionIndex: 0,
      ),
      ContractClause(
        id: 'kl_2',
        sectionTitle: '🍽️ Kuliner & Lifestyle',
        baseText: 'Eksplor restoran baru minimal [X] sebulan',
        options: ['1x', '2x'],
        selectedOptionIndex: 0,
      ),
      ContractClause(
        id: 'kl_3',
        sectionTitle: '🍽️ Kuliner & Lifestyle',
        baseText: 'Hari bebas masak = [X]',
        options: ['Rabu', 'Sabtu', 'Minggu'],
        selectedOptionIndex: 0,
      ),
      // 💑 Hubungan & Komitmen
      ContractClause(
        id: 'hk_1',
        sectionTitle: '💑 Hubungan & Komitmen',
        baseText: 'Tidak tidur dalam kondisi marah — selesaikan sebelum jam [X] malam',
        options: ['11', '12'],
        selectedOptionIndex: 0,
      ),
      ContractClause(
        id: 'hk_2',
        sectionTitle: '💑 Hubungan & Komitmen',
        baseText: 'Saling check-in: "Hari ini gimana?" minimal [X] sehari',
        options: ['1x', '2x'],
        selectedOptionIndex: 0,
      ),
      ContractClause(
        id: 'hk_3',
        sectionTitle: '💑 Hubungan & Komitmen',
        baseText: 'Apresiasi kecil: ucapkan terima kasih untuk hal sekecil apapun',
        options: [],
        selectedOptionIndex: -1,
      ),
      ContractClause(
        id: 'hk_4',
        sectionTitle: '💑 Hubungan & Komitmen',
        baseText: 'Quality time tanpa HP selama [X] per hari',
        options: ['30 menit', '1 jam'],
        selectedOptionIndex: 0,
      ),
      // 🎯 Goals Bersama
      ContractClause(
        id: 'gb_1',
        sectionTitle: '🎯 Goals Bersama',
        baseText: 'Nabung bareng untuk [CUSTOM] target [X] bulan',
        options: ['3', '6', '12'],
        selectedOptionIndex: 1,
        hasCustomText: true,
        customLabel: 'Tujuan',
      ),
      ContractClause(
        id: 'gb_2',
        sectionTitle: '🎯 Goals Bersama',
        baseText: 'Belajar skill baru bersama: [CUSTOM]',
        options: [],
        selectedOptionIndex: -1,
        hasCustomText: true,
        customLabel: 'Nama Skill',
      ),
      ContractClause(
        id: 'gb_3',
        sectionTitle: '🎯 Goals Bersama',
        baseText: 'Bucket list: selesaikan [X] item sebelum akhir tahun',
        options: ['1', '2', '3'],
        selectedOptionIndex: 0,
      ),
    ];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class LoveContractScreen extends StatefulWidget {
  const LoveContractScreen({super.key});

  @override
  State<LoveContractScreen> createState() => _LoveContractScreenState();
}

class _LoveContractScreenState extends State<LoveContractScreen> {
  static const _prefKey = 'love_contract_data';

  List<ContractClause> _clauses = [];
  bool _loading = true;
  bool _signed = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ── Persistence ──────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        setState(() {
          _clauses = list.map((e) => ContractClause.fromJson(e as Map<String, dynamic>)).toList();
          _loading = false;
        });
        return;
      } catch (_) {
        // fall through to defaults
      }
    }
    setState(() {
      _clauses = _buildDefaultClauses();
      _loading = false;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, jsonEncode(_clauses.map((c) => c.toJson()).toList()));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<String> get _sectionTitles {
    final seen = <String>[];
    for (final c in _clauses) {
      if (!seen.contains(c.sectionTitle)) seen.add(c.sectionTitle);
    }
    return seen;
  }

  List<ContractClause> _clausesForSection(String title) =>
      _clauses.where((c) => c.sectionTitle == title).toList();

  // ── Bottom sheets ─────────────────────────────────────────────────────────

  Future<void> _showOptionSheet(ContractClause clause, bool isAfterDark) async {
    int tempIndex = clause.selectedOptionIndex;
    final primary = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final surface = isAfterDark ? AppColors.darkSurface : AppColors.normalSurface;
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;

    await showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pilih opsi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(clause.options.length, (i) {
                return RadioListTile<int>(
                  value: i,
                  groupValue: tempIndex,
                  activeColor: primary,
                  title: Text(clause.options[i], style: TextStyle(color: textColor)),
                  onChanged: (v) => setModal(() => tempIndex = v!),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: 'Simpan',
                  onPressed: () {
                    setState(() {
                      clause.selectedOptionIndex = tempIndex;
                    });
                    _saveData();
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCustomTextSheet(ContractClause clause, bool isAfterDark) async {
    final controller = TextEditingController(text: clause.customTextValue);
    final surface = isAfterDark ? AppColors.darkSurface : AppColors.normalSurface;
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor = isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final primary = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;

    await showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              clause.customLabel,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Tulis ${clause.customLabel}...',
                hintStyle: TextStyle(color: mutedColor),
                filled: true,
                fillColor: isAfterDark
                    ? AppColors.darkCard.withValues(alpha: 0.6)
                    : AppColors.normalCard.withValues(alpha: 0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'Simpan',
                onPressed: () {
                  setState(() {
                    clause.customTextValue = controller.text;
                  });
                  _saveData();
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Signature dialog ──────────────────────────────────────────────────────

  Future<void> _showSignatureDialog(
      bool isAfterDark, String partner1, String partner2) async {
    final primary = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final secondary = isAfterDark ? AppColors.darkSecondary : AppColors.normalSecondary;
    final surface = isAfterDark ? AppColors.darkSurface : AppColors.normalSurface;
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor = isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Seal
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primary, secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('❤️', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Kontrak Cinta Tersegel!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Dengan penuh cinta & komitmen,\nkami menyetujui kontrak ini.',
                style: TextStyle(fontSize: 13, color: mutedColor, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _signatureBlock(partner1, primary, textColor, mutedColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('&', style: TextStyle(fontSize: 22, color: primary, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: _signatureBlock(partner2, secondary, textColor, mutedColor)),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                '✨ +30 XP diberikan ✨',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: 'Tutup',
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signatureBlock(String name, Color color, Color textColor, Color mutedColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: color, width: 2),
          bottom: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Column(
        children: [
          Text(
            name.isEmpty ? '—' : name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text('tanda tangan', style: TextStyle(fontSize: 10, color: mutedColor)),
        ],
      ),
    );
  }

  // ── Sign action ───────────────────────────────────────────────────────────

  Future<void> _onSign(bool isAfterDark, String partner1, String partner2) async {
    setState(() => _signed = true);
    context.read<BondProvider>().addXp(30);
    await _showSignatureDialog(isAfterDark, partner1, partner2);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kontrak tersimpan! +30 XP 🎉'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;
    final coupleProfile = context.watch<CoupleProvider>().profile;
    final partner1 = coupleProfile?.partner1 ?? 'Partner 1';
    final partner2 = coupleProfile?.partner2 ?? 'Partner 2';

    final bgTop = isAfterDark ? AppColors.darkBgTop : AppColors.normalBgTop;
    final bgBottom = isAfterDark ? AppColors.darkBgBottom : AppColors.normalBgBottom;
    final primary = isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final textColor = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor = isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final borderColor = isAfterDark ? AppColors.darkBorder : AppColors.normalBorder;

    // Document paper color
    final docBg = isAfterDark
        ? const Color(0xFF1E1A2E)
        : const Color(0xFFFFFBF2);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgTop, bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              _buildAppBar(context, textColor, mutedColor, primary),
              // Body
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildContent(
                        isAfterDark, docBg, textColor, mutedColor, borderColor, primary,
                        partner1, partner2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Color textColor, Color mutedColor, Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Love Contract 💍',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  'Kontrak cinta kita',
                  style: TextStyle(fontSize: 12, color: mutedColor),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primary.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium_rounded, color: primary, size: 14),
                const SizedBox(width: 4),
                Text('+30 XP', style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    bool isAfterDark,
    Color docBg,
    Color textColor,
    Color mutedColor,
    Color borderColor,
    Color primary,
    String partner1,
    String partner2,
  ) {
    final sections = _sectionTitles;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        children: [
          // Document card
          Container(
            decoration: BoxDecoration(
              color: docBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: borderColor.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                // Document header
                _buildDocumentHeader(textColor, mutedColor, primary, partner1, partner2, isAfterDark),
                // Sections
                ...sections.map((section) => _buildSection(
                      section,
                      isAfterDark,
                      textColor,
                      mutedColor,
                      borderColor,
                      primary,
                    )),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Sign button
          GradientButton(
            text: 'Tanda Tangan & Segel 💍',
            onPressed: _signed
                ? null
                : () => _onSign(isAfterDark, partner1, partner2),
          ),
          if (_signed)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Kontrak sudah ditandatangani!',
                    style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDocumentHeader(
    Color textColor,
    Color mutedColor,
    Color primary,
    String partner1,
    String partner2,
    bool isAfterDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: primary.withValues(alpha: 0.25), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            '❤️',
            style: const TextStyle(fontSize: 36),
          ),
          const SizedBox(height: 12),
          Text(
            'LOVE CONTRACT',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Kontrak Komitmen Cinta',
            style: TextStyle(
              fontSize: 13,
              color: mutedColor,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  primary.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _partnerBadge(partner1, primary, textColor, mutedColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('💑', style: const TextStyle(fontSize: 20)),
              ),
              _partnerBadge(partner2, primary, textColor, mutedColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _partnerBadge(String name, Color primary, Color textColor, Color mutedColor) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withValues(alpha: 0.15),
            border: Border.all(color: primary.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primary),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name.isEmpty ? '—' : name,
          style: TextStyle(fontSize: 13, color: textColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSection(
    String sectionTitle,
    bool isAfterDark,
    Color textColor,
    Color mutedColor,
    Color borderColor,
    Color primary,
  ) {
    final clauses = _clausesForSection(sectionTitle);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    sectionTitle,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 1,
            color: borderColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 4),
          ...clauses.map((clause) => _buildClauseRow(
                clause,
                isAfterDark,
                textColor,
                mutedColor,
                borderColor,
                primary,
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: borderColor.withValues(alpha: 0.3), height: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildClauseRow(
    ContractClause clause,
    bool isAfterDark,
    Color textColor,
    Color mutedColor,
    Color borderColor,
    Color primary,
  ) {
    final hasOptions = clause.options.isNotEmpty;
    final hasCustom = clause.hasCustomText;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox icon
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 18,
              color: primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 10),
          // Clause text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clause.renderedText,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor,
                    height: 1.5,
                  ),
                ),
                // Chips row
                if (hasOptions || hasCustom)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (hasOptions)
                          _editChip(
                            label: hasOptions && clause.selectedOptionIndex >= 0
                                ? clause.options[clause.selectedOptionIndex]
                                : 'Pilih',
                            color: primary,
                            onTap: () => _showOptionSheet(clause, isAfterDark),
                          ),
                        if (hasCustom)
                          _editChip(
                            label: clause.customTextValue.trim().isEmpty
                                ? clause.customLabel
                                : clause.customTextValue.trim(),
                            color: isAfterDark ? AppColors.darkSecondary : AppColors.normalSecondary,
                            onTap: () => _showCustomTextSheet(clause, isAfterDark),
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

  Widget _editChip({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit_rounded, size: 11, color: color),
          ],
        ),
      ),
    );
  }
}