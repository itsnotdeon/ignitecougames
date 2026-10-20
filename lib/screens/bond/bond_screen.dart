import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/achievements_data.dart';
import '../../providers/app_provider.dart';
import '../../providers/bond_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';

class BondScreen extends StatelessWidget {
  const BondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;
    final bond = context.watch<BondProvider>().progress;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Our Bond & XP'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // --- HERO LEVEL BADGE ---
            Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isAfterDark
                      ? const LinearGradient(colors: [AppColors.darkPrimary, Color(0xFF6B1130)])
                      : const LinearGradient(colors: [AppColors.normalPrimary, AppColors.normalSecondary]),
                  boxShadow: [
                    BoxShadow(
                      color: (isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 32)),
                      Text(
                        'LVL ${bond.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                bond.levelTitle,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '${bond.xp} / ${bond.nextLevelXp} Total XP',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            const SizedBox(height: 16),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: bond.progressToNextLevel,
                  minHeight: 10,
                  backgroundColor: (isAfterDark ? Colors.white : Colors.black).withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // --- STATS ROW ---
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    emoji: '🎮',
                    label: 'Game Selesai',
                    value: '${bond.gamesPlayed}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    emoji: '⚡',
                    label: 'Streak Cinta',
                    value: '${bond.streakDays} Hari',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    emoji: '🏆',
                    label: 'Lencana',
                    value: '${bond.unlockedAchievements.length}/${AchievementsData.all.length}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // --- ACHIEVEMENTS LIST ---
            Text(
              'Lencana Cinta (Achievements)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ...AchievementsData.all.map((ach) {
              final isUnlocked = bond.unlockedAchievements.contains(ach.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CustomCard(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: isUnlocked
                      ? null
                      : (isAfterDark ? const Color(0xFF150D1C) : const Color(0xFFF9F9F9)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isUnlocked
                              ? (isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary).withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.15),
                        ),
                        child: Text(
                          isUnlocked ? ach.icon : '🔒',
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ach.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isUnlocked ? null : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              ach.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: isUnlocked
                                    ? Theme.of(context).textTheme.bodyMedium?.color
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isUnlocked)
                        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String emoji,
    required String label,
    required String value,
  }) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}