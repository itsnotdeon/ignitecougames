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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TOP HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary).withOpacity(0.15),
                          border: Border.all(
                            color: isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          '${couple.emoji1}${couple.emoji2}',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            couple.displayName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Hari ke-${couple.daysTogether} bersama 💕',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Quick Theme Switcher Pill
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => app.toggleTheme(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isAfterDark ? AppColors.darkCard : AppColors.normalSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isAfterDark ? AppColors.darkBorder : AppColors.normalBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isAfterDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                            size: 16,
                            color: isAfterDark ? AppColors.darkAccent : AppColors.normalSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isAfterDark ? 'After Dark' : 'Normal',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isAfterDark ? AppColors.darkAccent : AppColors.normalSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- BOND PROGRESS BANNER ---
              CustomCard(
                onTap: () => app.setTabIndex(3), // Go to Bond Tab
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('🔥 ', style: TextStyle(fontSize: 18)),
                            Text(
                              'Level ${bond.level} • ${bond.levelTitle}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${bond.xp} XP',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: bond.progressToNextLevel,
                        minHeight: 8,
                        backgroundColor: (isAfterDark ? Colors.white : Colors.black).withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Streak: ${bond.streakDays} hari',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
                        ),
                        Text(
                          'Target: ${bond.nextLevelXp} XP',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- DAILY CONNECTION SPARK ---
              Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 20, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Text(
                    'Pertanyaan Hari Ini',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🌟 Deep Connection',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '"Apa hal kecil yang pasangamu lakukan belakangan ini yang membuat hatimu merasa hangat?"',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      text: 'Bahas Berdua (+25 XP)',
                      icon: Icons.chat_bubble_outline_rounded,
                      height: 44,
                      onPressed: () {
                        context.read<BondProvider>().addXp(25);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('✨ Keren! +25 XP ditambahkan ke Bond cinta kalian!'),
                            backgroundColor: isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              CustomCard(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HtmlSessionSetupScreen())),
                padding: const EdgeInsets.all(18),
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: (isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary).withOpacity(0.14), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.favorite_rounded)),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Mulai Sesi IGNITE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('Atur nama pemain dan ritual pemanasan dari HTML.'),
                  ])),
                  const Icon(Icons.chevron_right_rounded),
                ]),
              ),
              const SizedBox(height: 18),

              // --- QUICK GAME LAUNCH ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mainkan Sekarang',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => app.setTabIndex(1), // Go to Play tab
                    child: Text(
                      'Lihat Semua →',
                      style: TextStyle(
                        color: isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Truth or Dare Card
                  Expanded(
                    child: CustomCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TruthOrDareScreen(),
                          ),
                        );
                      },
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🃏', style: TextStyle(fontSize: 32)),
                          const SizedBox(height: 12),
                          const Text(
                            'Truth or Dare',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Momen intim & jujur',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Snake & Ladder Card
                  Expanded(
                    child: CustomCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SnakeLadderScreen(),
                          ),
                        );
                      },
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🎲', style: TextStyle(fontSize: 32)),
                          const SizedBox(height: 12),
                          const Text(
                            'Snake & Ladder',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Papan cinta interaktif',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}