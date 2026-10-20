import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Shared design system. Individual screens should consume ThemeData and tokens
/// instead of inventing their own spacing, borders, typography or control styles.
class AppTheme {
  static ThemeData normalTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.normalBgTop,
      colorScheme: const ColorScheme.light(
        primary: AppColors.normalPrimary,
        secondary: AppColors.normalSecondary,
        surface: AppColors.normalSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.normalText,
        error: Color(0xFFB3263E),
      ),
      fontFamily: GoogleFonts.poppins().fontFamily,
      visualDensity: VisualDensity.standard,
      splashFactory: InkRipple.splashFactory,
    );
    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: AppColors.normalText,
        displayColor: AppColors.normalText,
      ).copyWith(
        headlineLarge: GoogleFonts.playfairDisplay(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.normalText, height: 1.12),
        headlineMedium: GoogleFonts.playfairDisplay(fontSize: 25, fontWeight: FontWeight.w700, color: AppColors.normalText, height: 1.15),
        titleLarge: GoogleFonts.playfairDisplay(fontSize: 21, fontWeight: FontWeight.w700, color: AppColors.normalText),
        titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.normalText),
        bodyMedium: const TextStyle(fontSize: 14, height: 1.45, color: AppColors.normalTextMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.normalSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: const TextStyle(color: AppColors.normalTextMuted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.normalBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.normalBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.normalPrimary, width: 1.5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          backgroundColor: AppColors.normalPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.normalBorder,
          disabledForegroundColor: AppColors.normalTextMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 46),
          foregroundColor: AppColors.normalDeep,
          side: const BorderSide(color: AppColors.normalBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.normalCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: AppColors.normalBorder)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.normalText),
        iconTheme: const IconThemeData(color: AppColors.normalText),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.normalBorder, thickness: 1, space: 1),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.normalHighlight,
        selectedColor: AppColors.normalPrimary.withValues(alpha: 0.16),
        side: const BorderSide(color: AppColors.normalBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: const TextStyle(color: AppColors.normalDeep, fontWeight: FontWeight.w500),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.normalPrimary, linearTrackColor: AppColors.normalBorder),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.normalDeep,
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.normalSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.normalText),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.normalSurface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
    );
  }

  static ThemeData darkTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBgTop,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        surface: AppColors.darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkText,
        error: Color(0xFFFF8B9D),
      ),
      fontFamily: GoogleFonts.poppins().fontFamily,
      visualDensity: VisualDensity.standard,
      splashFactory: InkRipple.splashFactory,
    );
    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: AppColors.darkText,
        displayColor: AppColors.darkText,
      ).copyWith(
        headlineLarge: GoogleFonts.playfairDisplay(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.darkText, height: 1.12),
        headlineMedium: GoogleFonts.playfairDisplay(fontSize: 25, fontWeight: FontWeight.w700, color: AppColors.darkText, height: 1.15),
        titleLarge: GoogleFonts.playfairDisplay(fontSize: 21, fontWeight: FontWeight.w700, color: AppColors.darkText),
        titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkText),
        bodyMedium: const TextStyle(fontSize: 14, height: 1.45, color: AppColors.darkTextMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: const TextStyle(color: AppColors.darkTextMuted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.darkBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.darkBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.darkAccent, width: 1.5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.darkBorder,
          disabledForegroundColor: AppColors.darkTextMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 46),
          foregroundColor: AppColors.darkText,
          side: const BorderSide(color: AppColors.darkBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: AppColors.darkBorder)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkText),
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.darkBorder, thickness: 1, space: 1),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.darkHighlight,
        selectedColor: AppColors.darkPrimary.withValues(alpha: 0.22),
        side: const BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: const TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w500),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.darkAccent, linearTrackColor: AppColors.darkBorder),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkCard,
        contentTextStyle: const TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkText),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
    );
  }
}
