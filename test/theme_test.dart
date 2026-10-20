import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ignite_couple_games/theme/app_colors.dart';

void main() {
  group('IGNITE theme identity', () {
    test('Normal Mode keeps its warm, blush palette', () {
      expect(AppColors.normalBgTop, const Color(0xFFFFF0F2));
      expect(AppColors.normalPrimary, const Color(0xFFBD526D));
      expect(AppColors.normalText, isNot(AppColors.darkText));
    });

    test('After Dark stays visually distinct and deep', () {
      expect(AppColors.darkBgTop, const Color(0xFF100914));
      expect(AppColors.darkPrimary, const Color(0xFFD34F75));
      expect(AppColors.darkBgTop, isNot(AppColors.normalBgTop));
      expect(AppColors.darkCard, isNot(AppColors.normalCard));
    });
  });
}