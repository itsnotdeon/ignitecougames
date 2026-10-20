import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _drawRandomCard();
  }

  void _drawRandomCard({CardType? type}) {
    final isAfterDark = context.read<AppProvider>().isAfterDark;
    List<GameCard> filtered = TruthOrDareData.cards.where((c) {
      if (!isAfterDark && c.isAfterDark) return false;
      if (_selectedCategory != null && c.category != _selectedCategory) return false;
      if (type != null && c.type != type) return false;
      return true;
    }).toList();

    if (filtered.isEmpty) {
      // Never fall back to After Dark content while Normal Mode is active.
      // If a selected type/category has no cards, use only content allowed by the current theme.
      filtered = TruthOrDareData.cards.where((card) => isAfterDark || !card.isAfterDark).toList();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Truth or Dare'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // --- TURN INDICATOR ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: (isAfterDark ? AppColors.darkCard : AppColors.normalCard),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isAfterDark ? AppColors.darkBorder : AppColors.normalBorder),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(activeEmoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'Giliran: $activePartner',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- CATEGORY FILTER CHIPS ---
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

              const SizedBox(height: 20),

              // --- THE CARD ---
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _cardRevealed = !_cardRevealed;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
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
                                colors: [AppColors.normalCard, AppColors.normalHighlight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: _currentCard?.type == CardType.dare
                              ? (isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary)
                              : (isAfterDark ? AppColors.darkSecondary : AppColors.normalSecondary),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary)
                                .withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Card Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: (_currentCard?.type == CardType.dare
                                      ? (isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary)
                                      : (isAfterDark ? AppColors.darkSecondary : AppColors.normalSecondary))
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _currentCard?.type == CardType.dare ? '🔥 DARE' : '💬 TRUTH',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 1.2,
                                color: _currentCard?.type == CardType.dare
                                    ? (isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary)
                                    : (isAfterDark ? AppColors.darkSecondary : AppColors.normalSecondary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Text Content
                          if (_cardRevealed) ...[
                            Text(
                              _currentCard?.text ?? 'Sentuh kartu untuk membuka...',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Reward: +${_currentCard?.xpReward ?? 20} XP',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary,
                              ),
                            ),
                          ] else ...[
                            Icon(
                              Icons.touch_app_rounded,
                              size: 48,
                              color: isAfterDark ? AppColors.darkAccent : AppColors.normalSecondary,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Sentuh untuk Membuka Kartu',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tatap matanya saat kartu terbuka...',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- ACTION BUTTONS ---
              Row(
                children: [
                  Expanded(
                    child: GradientButton(
                      text: 'Truth Baru',
                      icon: Icons.chat_bubble_outline_rounded,
                      isSecondary: true,
                      onPressed: () => _drawRandomCard(type: CardType.truth),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      text: 'Dare Baru',
                      icon: Icons.flash_on_rounded,
                      isSecondary: true,
                      onPressed: () => _drawRandomCard(type: CardType.dare),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: 'Tantangan Selesai (+XP) →',
                  icon: Icons.check_circle_rounded,
                  onPressed: _completeChallenge,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
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