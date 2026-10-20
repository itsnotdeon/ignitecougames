import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/couple_provider.dart';
import '../../providers/bond_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/gradient_button.dart';
import '../play/truth_or_dare_screen.dart';
import '../play/snake_ladder_screen.dart';
import 'html_session_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final couple = context.watch<CoupleProvider>().profile;
    final bond = context.watch<BondProvider>().progress;
    final isAfterDark = app.isAfterDark;
    final accent = isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary;
    final muted = isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted;
    final border = isAfterDark ? AppColors.darkBorder : AppColors.normalBorder;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 720 ? 32.0 : 20.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 18, horizontalPadding, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Couple identity and quick theme control.
                      Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent.withValues(alpha: 0.12),
                              border: Border.all(color: accent.withValues(alpha: 0.45)),
                            ),
                            child: Text('${couple.emoji1}${couple.emoji2}', style: const TextStyle(fontSize: 21)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(couple.displayName, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 3),
                                Text('Hari ke-${couple.daysTogether} bersama', style: TextStyle(fontSize: 12, color: muted)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Tooltip(
                            message: isAfterDark ? 'Beralih ke Normal Mode' : 'Beralih ke After Dark',
                            child: Material(
                              color: isAfterDark ? AppColors.darkCard : AppColors.normalSurface,
                              shape: const StadiumBorder(),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: app.toggleTheme,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: border),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(isAfterDark ? Icons.nightlight_round : Icons.wb_twilight_rounded, size: 16, color: accent),
                                      const SizedBox(width: 6),
                                      Text(isAfterDark ? 'After Dark' : 'Normal',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accent)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Editorial welcome and primary action.
                      Container(
                        width: double.infinity,
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
                          border: Border.all(color: accent.withValues(alpha: 0.28)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                              decoration: BoxDecoration(
                                color: (isAfterDark ? Colors.white : AppColors.normalDeep).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text('A LITTLE MORE US  ·  IGNITE', style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: isAfterDark ? AppColors.darkAccent : AppColors.normalDeep)),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Dekat, satu\ncerita setiap hari.',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(height: 1.12),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Ruang kecil untuk bermain, bercerita, dan menemukan hal baru tentang satu sama lain.',
                              style: TextStyle(fontSize: 13, height: 1.55, color: isAfterDark ? AppColors.darkTextMuted : AppColors.normalTextMuted),
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              width: double.infinity,
                              child: GradientButton(
                                text: 'Mulai Sesi IGNITE',
                                icon: Icons.favorite_rounded,
                                height: 52,
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HtmlSessionSetupScreen())),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Relationship progression card.
                      CustomCard(
                        onTap: () => app.setTabIndex(3),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                                  child: Icon(Icons.local_fire_department_rounded, color: accent, size: 21),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Ikatan kalian', style: Theme.of(context).textTheme.titleMedium),
                                      const SizedBox(height: 2),
                                      Text('Level ${bond.level} · ${bond.levelTitle}', style: TextStyle(fontSize: 12, color: muted)),
                                    ],
                                  ),
                                ),
                                Text('${bond.xp} XP', style: TextStyle(fontWeight: FontWeight.w800, color: accent)),
                                const SizedBox(width: 4),
                                Icon(Icons.chevron_right_rounded, color: muted),
                              ],
                            ),
                            const SizedBox(height: 18),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                value: bond.progressToNextLevel.clamp(0.0, 1.0),
                                minHeight: 7,
                                backgroundColor: border.withValues(alpha: 0.6),
                                valueColor: AlwaysStoppedAnimation<Color>(accent),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('🔥 Streak ${bond.streakDays} hari', style: TextStyle(fontSize: 11, color: muted)),
                                Text('Berikutnya ${bond.nextLevelXp} XP', style: TextStyle(fontSize: 11, color: muted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      Row(
                        children: [
                          Container(width: 4, height: 24, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(8))),
                          const SizedBox(width: 10),
                          Expanded(child: Text('Momen hari ini', style: Theme.of(context).textTheme.headlineMedium)),
                          Icon(Icons.auto_awesome_rounded, color: isAfterDark ? AppColors.darkSecondary : AppColors.normalSecondary),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CustomCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.forum_rounded, size: 17, color: accent),
                                const SizedBox(width: 8),
                                Text('DEEP CONNECTION', style: TextStyle(fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w800, color: accent)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              '“Apa hal kecil yang pasanganmu lakukan belakangan ini yang membuat hatimu merasa hangat?”',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17, height: 1.5, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: GradientButton(
                                text: 'Kami sudah membahasnya  ·  +25 XP',
                                icon: Icons.check_circle_outline_rounded,
                                height: 48,
                                onPressed: () {
                                  context.read<BondProvider>().addXp(25);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: const Text('Bagus! +25 XP untuk ikatan kalian 💗'), backgroundColor: isAfterDark ? AppColors.darkCard : AppColors.normalDeep),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('Pilih permainan', style: Theme.of(context).textTheme.headlineMedium)),
                          TextButton(onPressed: () => app.setTabIndex(1), child: Text('Lihat semua  →', style: TextStyle(color: accent, fontWeight: FontWeight.w700))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, gridConstraints) {
                          final columns = gridConstraints.maxWidth >= 620 ? 4 : 2;
                          final cardWidth = (gridConstraints.maxWidth - (columns - 1) * 12) / columns;
                          final games = [
                            _QuickGame(icon: '🃏', title: 'Truth or Dare', subtitle: 'Jujur & berani', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TruthOrDareScreen())), accent: accent),
                            _QuickGame(icon: '🎲', title: 'Ular Tangga', subtitle: 'Papan cinta', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SnakeLadderScreen())), accent: accent),
                          ];
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: games.map((game) => SizedBox(width: columns == 2 ? cardWidth : (cardWidth * 2 + 12), child: game)).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QuickGame extends StatelessWidget {
  const _QuickGame({required this.icon, required this.title, required this.subtitle, required this.onTap, required this.accent});

  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(15)),
            child: Text(icon, style: const TextStyle(fontSize: 25)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_rounded, size: 17, color: accent),
        ],
      ),
    );
  }
}
