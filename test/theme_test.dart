import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ignite_couple_games/theme/app_colors.dart';

void main() {
  group('IGNITE theme identity', () {
    test('Normal Mode keeps its warm, blush palette', () {
      expect(AppColors.normalBgTop, const Color(0xFFFFF7F8));
      expect(AppColors.normalPrimary, const Color(0xFFE26D7D));
      expect(AppColors.normalText, isNot(AppColors.darkText));
    });

    test('After Dark stays visually distinct and deep', () {
      expect(AppColors.darkBgTop, const Color(0xFF0F0714));
      expect(AppColors.darkPrimary, const Color(0xFFD43A60));
      expect(AppColors.darkBgTop, isNot(AppColors.normalBgTop));
      expect(AppColors.darkCard, isNot(AppColors.normalCard));
    });
  });
}