import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/truth_or_dare_data.dart';
import '../../models/game_card.dart';
import '../../providers/app_provider.dart';
import '../../providers/bond_provider.dart';
import '../../providers/couple_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';

class TruthOrDareScreen extends StatefulWidget {
  const TruthOrDareScreen({super.key});

  @override
  State<TruthOrDareScreen> createState() => _TruthOrDareScreenState();
}

class _TruthOrDareScreenState extends State<TruthOrDareScreen> {
  CardCategory? _selectedCategory;
  int _currentTurn = 1; // 1 for partner1, 2 for partner2
  GameCard? _currentCard;
  bool _cardRevealed = false;
  List<GameCard> _importedHtmlCards = <GameCard>[];

  @override
  void initState() {
    super.initState();
    _loadImportedHtmlCards();
    _drawRandomCard();
  }

  Future<void> _loadImportedHtmlCards() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('ignite_html_compatible_topics_snapshot');
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw);
      final categories = decoded is Map ? decoded['totCategories'] : null;
      if (categories is! List) return;
      final imported = <GameCard>[];
      for (final category in categories) {
        if (category is! Map || category['topics'] is! List) continue;
        final name = (category['name'] ?? '').toString().toLowerCase();
        final type = name.contains('dare') ? CardType.dare : CardType.truth;
        final topics = (category['topics'] as List).whereType<String>();
        var index = 0;
        for (final topic in topics) {
          if (topic.trim().isEmpty) continue;
          imported.add(GameCard(
            id: 'imported_html_${type.name}_${index++}_${topic.hashCode}',
            type: type,
            category: CardCategory.deep,
            text: topic,
            xpReward: 20,
          ));
        }
      }
      if (mounted && imported.isNotEmpty) {
        setState(() => _importedHtmlCards = imported);
        _drawRandomCard();
      }
    } catch (_) {
      // A malformed optional import must not prevent the built-in game from running.
    }
  }

  void _drawRandomCard({CardType? type}) {
    final isAfterDark = context.read<AppProvider>().isAfterDark;
    final allCards = <GameCard>[...TruthOrDareData.cards, ..._importedHtmlCards];
    List<GameCard> filtered = allCards.where((c) {
      if (!isAfterDark && c.isAfterDark) return false;
      if (_selectedCategory != null && c.category != _selectedCategory) return false;
      if (type != null && c.type != type) return false;
      return true;
    }).toList();

    if (filtered.isEmpty) {
      // Never fall back to After Dark content while Normal Mode is active.
      // If a selected type/category has no cards, use only content allowed by the current theme.
      filtered = allCards.where((card) => isAfterDark || !card.isAfterDark).toList();
    }

    final random = Random();
    setState(() {
      _currentCard = filtered[random.nextInt(filtered.length)];
      _cardRevealed = false;
    });
  }

  void _completeChallenge() {
    if (_currentCard == null) return;
    context.read<BondProvider>().addXp(_currentCard!.xpReward);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Tantangan selesai! +${_currentCard!.xpReward} XP'),
        backgroundColor: AppColors.loveRed,
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _currentTurn = _currentTurn == 1 ? 2 : 1;
    });
    _drawRandomCard();
  }

  @override
  Widget build(BuildContext context) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;
    final couple = context.watch<CoupleProvider>().profile;
    final activePartner = _currentTurn == 1 ? couple.partner1 : couple.partner2;
    final activeEmoji = _currentTurn == 1 ? couple.emoji1 : couple.emoji2;
    final primary = isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary;
    final muted = isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final foreground = isAfterDark ? AppColors.darkText : AppColors.normalText;
    final surface = isAfterDark ? AppColors.darkCard : AppColors.normalCard;
    final cardTypeColor = _currentCard?.type == CardType.dare
        ? (isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary)
        : (isAfterDark ? AppColors.darkSecondary : AppColors.normalSecondary);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Truth or Dare')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Jujur, berani, dan semakin dekat.', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih kartu yang terasa nyaman. Kalian boleh melewati tantangan kapan saja tanpa harus menjelaskan alasannya.',
                      style: TextStyle(color: muted, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: isAfterDark ? AppColors.darkBorder : AppColors.normalBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(activeEmoji, style: const TextStyle(fontSize: 21)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('GILIRAN SEKARANG', style: TextStyle(color: muted, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 3),
                                Text(activePartner, style: TextStyle(color: foreground, fontWeight: FontWeight.w700, fontSize: 16)),
                              ],
                            ),
                          ),
                          Icon(Icons.favorite_rounded, color: primary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('Pilih suasana', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryChip(null, '✨ Semua'),
                          const SizedBox(width: 8),
                          _buildCategoryChip(CardCategory.romantic, '🌹 Romantic'),
                          const SizedBox(width: 8),
                          _buildCategoryChip(CardCategory.deep, '🌊 Deep Talk'),
                          if (isAfterDark) ...[
                            const SizedBox(width: 8),
                            _buildCategoryChip(CardCategory.spicy, '🔥 Spicy'),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => setState(() => _cardRevealed = !_cardRevealed),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        constraints: const BoxConstraints(minHeight: 300),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isAfterDark
                                ? const [Color(0xFF442038), Color(0xFF211326), Color(0xFF17101E)]
                                : const [Color(0xFFFFDDE5), Color(0xFFFFEEF0), Color(0xFFF9E4D8)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: cardTypeColor.withValues(alpha: 0.45), width: 1.4),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: isAfterDark ? 0.12 : 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(_currentCard?.type == CardType.dare ? Icons.bolt_rounded : Icons.chat_bubble_rounded, color: cardTypeColor, size: 19),
                                const SizedBox(width: 8),
                                Text(
                                  _currentCard?.type == CardType.dare ? 'DARE' : 'TRUTH',
                                  style: TextStyle(color: cardTypeColor, fontSize: 11, letterSpacing: 1.6, fontWeight: FontWeight.w900),
                                ),
                                const Spacer(),
                                Icon(Icons.auto_awesome_rounded, color: isAfterDark ? AppColors.gold : AppColors.normalSecondary),
                              ],
                            ),
                            const SizedBox(height: 24),
                            if (_cardRevealed) ...[
                              Text(
                                _currentCard?.text ?? 'Kartu belum tersedia.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: foreground, fontSize: 21, height: 1.45, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 22),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(color: surface.withValues(alpha: 0.78), borderRadius: BorderRadius.circular(30)),
                                  child: Text('+${_currentCard?.xpReward ?? 20} XP jika diselesaikan', style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 30),
                              Icon(Icons.touch_app_rounded, size: 44, color: cardTypeColor),
                              const SizedBox(height: 16),
                              Text('Sentuh kartu untuk membuka', textAlign: TextAlign.center, style: TextStyle(color: foreground, fontSize: 18, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              Text('Ambil napas, saling tatap, lalu mulai saat siap.', textAlign: TextAlign.center, style: TextStyle(color: muted, height: 1.4)),
                              const SizedBox(height: 30),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _drawRandomCard(type: CardType.truth),
                            icon: const Icon(Icons.chat_bubble_outline_rounded),
                            label: const Text('Truth baru'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _drawRandomCard(type: CardType.dare),
                            icon: const Icon(Icons.bolt_rounded),
                            label: const Text('Dare baru'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: _completeChallenge,
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Selesai & ganti giliran'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hadiah XP diberikan saat kalian menandai tantangan selesai. Persetujuan dan kenyamanan kalian tetap lebih penting daripada menyelesaikan kartu.',
                      style: TextStyle(color: muted, fontSize: 12, height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(CardCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    final isAfterDark = context.watch<AppProvider>().isAfterDark;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedCategory = category;
          _drawRandomCard();
        });
      },
      selectedColor: (isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary).withOpacity(0.25),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? (isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary)
            : Theme.of(context).textTheme.bodyMedium?.color,
      ),
    );
  }
}