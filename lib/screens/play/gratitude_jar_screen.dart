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
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_card.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class GratitudeEntry {
  final String id;
  final String authorName;
  final String recipientName;
  final String text;
  final DateTime date;
  final String emoji;

  const GratitudeEntry({
    required this.id,
    required this.authorName,
    required this.recipientName,
    required this.text,
    required this.date,
    required this.emoji,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'authorName': authorName,
        'recipientName': recipientName,
        'text': text,
        'date': date.toIso8601String(),
        'emoji': emoji,
      };

  factory GratitudeEntry.fromMap(Map<String, dynamic> map) => GratitudeEntry(
        id: map['id'] as String,
        authorName: map['authorName'] as String,
        recipientName: map['recipientName'] as String,
        text: map['text'] as String,
        date: DateTime.parse(map['date'] as String),
        emoji: map['emoji'] as String,
      );
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const List<String> _emojiPool = [
  '💖',
  '🌟',
  '🌸',
  '✨',
  '🥰',
  '💕',
  '🌹',
  '🎀',
];

const String _storageKey = 'gratitude_entries';
const int _xpPerEntry = 10;
const _uuid = Uuid();

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class GratitudeJarScreen extends StatefulWidget {
  const GratitudeJarScreen({super.key});

  @override
  State<GratitudeJarScreen> createState() => _GratitudeJarScreenState();
}

class _GratitudeJarScreenState extends State<GratitudeJarScreen>
    with SingleTickerProviderStateMixin {
  List<GratitudeEntry> _entries = [];
  bool _isLoading = true;

  // Which author perspective is active for input (1 = partner1, 2 = partner2)
  int _activeAuthor = 1;
  final TextEditingController _textController = TextEditingController();
  bool _isSaving = false;

  // "Open Together" reveal animation
  GratitudeEntry? _revealedEntry;
  late AnimationController _revealController;
  late Animation<double> _revealScale;
  late Animation<double> _revealOpacity;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _revealScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.elasticOut),
    );
    _revealOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeIn),
    );
    _loadEntries();
  }

  @override
  void dispose() {
    _textController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Storage helpers
  // ---------------------------------------------------------------------------

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
        _entries = decoded
            .map((e) => GratitudeEntry.fromMap(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      } catch (_) {
        _entries = [];
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_entries.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _addEntry() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final couple = context.read<CoupleProvider>().profile;
    final authorName =
        _activeAuthor == 1 ? couple.partner1 : couple.partner2;
    final recipientName =
        _activeAuthor == 1 ? couple.partner2 : couple.partner1;
    final emoji = _emojiPool[_random.nextInt(_emojiPool.length)];

    final entry = GratitudeEntry(
      id: _uuid.v4(),
      authorName: authorName,
      recipientName: recipientName,
      text: text,
      date: DateTime.now(),
      emoji: emoji,
    );

    setState(() {
      _isSaving = true;
      _entries.insert(0, entry);
    });

    await _saveEntries();
    if (mounted) {
      context.read<BondProvider>().addXp(_xpPerEntry);
      _textController.clear();
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$emoji Tersimpan! +$_xpPerEntry XP'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _openTogether() {
    if (_entries.isEmpty) return;
    final picked = _entries[_random.nextInt(_entries.length)];
    setState(() => _revealedEntry = picked);
    _revealController.forward(from: 0);
    _showRevealDialog(picked);
  }

  void _showRevealDialog(GratitudeEntry entry) {
    final isAfterDark = context.read<AppProvider>().isAfterDark;
    final primaryColor =
        isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary;
    final textColor =
        isAfterDark ? AppColors.darkText : AppColors.normalText;
    final mutedColor =
        isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final bgColor =
        isAfterDark ? AppColors.darkSurface : AppColors.normalSurface;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ScaleTransition(
          scale: _revealScale,
          child: FadeTransition(
            opacity: _revealOpacity,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(entry.emoji,
                      style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    '${entry.authorName} untuk ${entry.recipientName}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      entry.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatDate(entry.date),
                    style:
                        TextStyle(fontSize: 12, color: mutedColor),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      text: 'Tutup 💌',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteEntry(GratitudeEntry entry) async {
    setState(() {
      _entries.removeWhere((e) => e.id == entry.id);
    });
    await _saveEntries();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

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

    final partner1Entries =
        _entries.where((e) => e.authorName == couple.partner1).toList();
    final partner2Entries =
        _entries.where((e) => e.authorName == couple.partner2).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gratitude Jar 💌'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // --- Message count banner ---
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isAfterDark
                            ? [
                                AppColors.darkPrimary.withValues(alpha: 0.25),
                                AppColors.darkSecondary.withValues(alpha: 0.15),
                              ]
                            : [
                                AppColors.normalPrimary.withValues(alpha: 0.12),
                                AppColors.normalAccent.withValues(alpha: 0.08),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('💌',
                            style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${_entries.length} pesan cinta tersimpan 💌',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        // Open Together button
                        GestureDetector(
                          onTap: _entries.isEmpty ? null : _openTogether,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '🎁 Buka Bersama',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- Author toggle ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _authorToggle(
                              1,
                              '${couple.emoji1} ${couple.partner1}',
                              isAfterDark,
                              primaryColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _authorToggle(
                              2,
                              '${couple.emoji2} ${couple.partner2}',
                              isAfterDark,
                              primaryColor),
                        ),
                      ],
                    ),
                  ),

                  // --- Text input ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isAfterDark
                                  ? AppColors.darkCard
                                  : AppColors.normalCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: TextField(
                              controller: _textController,
                              maxLines: 2,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText:
                                    'Tulis hal yang kamu syukuri tentang pasanganmu...',
                                hintStyle: TextStyle(
                                  color: mutedColor,
                                  fontSize: 13,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _isSaving ? null : _addEntry,
                          child: Container(
                            width: 50,
                            height: 58,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  isAfterDark
                                      ? AppColors.darkAccent
                                      : AppColors.normalAccent,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: _isSaving
                                ? const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Entries list ---
                  Expanded(
                    child: _entries.isEmpty
                        ? _buildEmptyState(mutedColor, primaryColor)
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (partner1Entries.isNotEmpty) ...[
                                  _sectionHeader(
                                    'Dari ${couple.partner1} ${couple.emoji1}',
                                    partner1Entries.length,
                                    primaryColor,
                                  ),
                                  const SizedBox(height: 10),
                                  ...partner1Entries.map(
                                    (e) => _buildEntryCard(
                                        e, isAfterDark, primaryColor, mutedColor),
                                  ),
                                  const SizedBox(height: 18),
                                ],
                                if (partner2Entries.isNotEmpty) ...[
                                  _sectionHeader(
                                    'Dari ${couple.partner2} ${couple.emoji2}',
                                    partner2Entries.length,
                                    isAfterDark
                                        ? AppColors.darkSecondary
                                        : AppColors.normalSecondary,
                                  ),
                                  const SizedBox(height: 10),
                                  ...partner2Entries.map(
                                    (e) => _buildEntryCard(
                                        e,
                                        isAfterDark,
                                        isAfterDark
                                            ? AppColors.darkSecondary
                                            : AppColors.normalSecondary,
                                        mutedColor),
                                  ),
                                  const SizedBox(height: 18),
                                ],
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _authorToggle(
      int index, String label, bool isAfterDark, Color primaryColor) {
    final isSelected = _activeAuthor == index;
    return GestureDetector(
      onTap: () => setState(() => _activeAuthor = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isAfterDark
                    ? AppColors.darkBorder
                    : AppColors.normalBorder),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? primaryColor
                : (isAfterDark
                    ? AppColors.darkTextMuted
                    : AppColors.normalTextMuted),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(
    GratitudeEntry entry,
    bool isAfterDark,
    Color accentColor,
    Color mutedColor,
  ) {
    final textColor =
        isAfterDark ? AppColors.darkText : AppColors.normalText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(entry.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.loveRed.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.delete_rounded,
              color: AppColors.loveRed, size: 22),
        ),
        onDismissed: (_) => _deleteEntry(entry),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isAfterDark ? AppColors.darkCard : AppColors.normalCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.emoji,
                  style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(entry.date),
                      style: TextStyle(
                        fontSize: 11,
                        color: mutedColor,
                      ),
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

  Widget _buildEmptyState(Color mutedColor, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🫙', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            'Toples masih kosong...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai isi dengan hal-hal yang\nkamu syukuri tentang pasanganmu 💕',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: mutedColor),
          ),
        ],
      ),
    );
  }
}