import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import 'home/home_screen.dart';
import 'play/play_screen.dart';
import 'memories/memories_screen.dart';
import 'bond/bond_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    PlayScreen(),
    MemoriesScreen(),
    BondScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final isAfterDark = app.isAfterDark;
    final currentIndex = app.currentTabIndex.clamp(0, _screens.length - 1);
    final accent = isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary;
    final border = isAfterDark ? AppColors.darkBorder : AppColors.normalBorder;
    final navSurface = isAfterDark ? AppColors.darkSurface : AppColors.normalSurface;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAfterDark
              ? const [AppColors.darkBgTop, AppColors.darkBgBottom]
              : const [AppColors.normalBgTop, AppColors.normalBgBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: navSurface.withValues(alpha: 0.97),
              border: Border(top: BorderSide(color: border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isAfterDark ? 0.18 : 0.045),
                  blurRadius: 22,
                  offset: const Offset(0, -7),
                ),
              ],
            ),
            child: NavigationBar(
              height: 70,
              selectedIndex: currentIndex,
              onDestinationSelected: app.setTabIndex,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              indicatorColor: accent.withValues(alpha: 0.14),
              indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.favorite_border_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded, color: accent),
                  tooltip: 'Beranda',
                  label: 'Beranda',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.sports_esports_outlined),
                  selectedIcon: Icon(Icons.sports_esports_rounded, color: accent),
                  tooltip: 'Permainan',
                  label: 'Main',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.photo_library_outlined),
                  selectedIcon: Icon(Icons.photo_library_rounded, color: accent),
                  tooltip: 'Kenangan',
                  label: 'Kenangan',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.local_fire_department_outlined),
                  selectedIcon: Icon(Icons.local_fire_department_rounded, color: accent),
                  tooltip: 'Ikatan',
                  label: 'Ikatan',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded, color: accent),
                  tooltip: 'Profil',
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
