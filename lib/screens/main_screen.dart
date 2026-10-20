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
    final currentIndex = app.currentTabIndex;

    final bgGradient = isAfterDark
        ? const LinearGradient(
            colors: [AppColors.darkBgTop, AppColors.darkBgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [AppColors.normalBgTop, AppColors.normalBgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return Container(
      decoration: BoxDecoration(gradient: bgGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isAfterDark ? AppColors.darkCard : AppColors.normalSurface,
            border: Border(
              top: BorderSide(
                color: isAfterDark ? AppColors.darkBorder : AppColors.normalBorder,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => app.setTabIndex(index),
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: (isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary).withOpacity(0.18),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.favorite_border_rounded),
                selectedIcon: Icon(
                  Icons.favorite_rounded,
                  color: isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary,
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.sports_esports_outlined),
                selectedIcon: Icon(
                  Icons.sports_esports_rounded,
                  color: isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary,
                ),
                label: 'Play',
              ),
              NavigationDestination(
                icon: const Icon(Icons.photo_library_outlined),
                selectedIcon: Icon(
                  Icons.photo_library_rounded,
                  color: isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary,
                ),
                label: 'Memories',
              ),
              NavigationDestination(
                icon: const Icon(Icons.local_fire_department_outlined),
                selectedIcon: Icon(
                  Icons.local_fire_department_rounded,
                  color: isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary,
                ),
                label: 'Bond',
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(
                  Icons.person_rounded,
                  color: isAfterDark ? AppColors.darkAccent : AppColors.normalPrimary,
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}