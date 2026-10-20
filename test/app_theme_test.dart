import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ignite_couple_games/theme/app_colors.dart';
import 'package:ignite_couple_games/theme/app_theme.dart';

void main() {
  group('IGNITE design system', () {
    test('Normal Mode uses a warm blush surface rather than plain white', () {
      final theme = AppTheme.normalTheme();

      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppColors.normalBgTop);
      expect(AppColors.normalBgTop, isNot(Colors.white));
      expect(theme.colorScheme.primary, AppColors.normalPrimary);
    });

    test('After Dark is a distinct, deep romantic theme', () {
      final theme = AppTheme.darkTheme();

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.darkBgTop);
      expect(AppColors.darkBgTop, isNot(AppColors.normalBgTop));
      expect(AppColors.darkCard, isNot(AppColors.normalCard));
      expect(theme.colorScheme.primary, AppColors.darkPrimary);
    });

    test('both themes provide consistent, touch-friendly input and button styles', () {
      for (final theme in [AppTheme.normalTheme(), AppTheme.darkTheme()]) {
        expect(theme.elevatedButtonTheme.style, isNotNull);
        expect(theme.inputDecorationTheme.contentPadding, isNotNull);
        expect(theme.cardTheme.shape, isNotNull);
        expect(theme.appBarTheme.titleTextStyle, isNotNull);
      }
    });
  });
}
