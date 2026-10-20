import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';

class GradientButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final bool isSecondary;

  const GradientButton({
    super.key,
    this.text,
    this.child,
    required this.onPressed,
    this.icon,
    this.height = 52,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;
    final isEnabled = onPressed != null;

    final primaryGradient = isAfterDark
        ? const LinearGradient(
            colors: [AppColors.darkPrimary, Color(0xFF9E1F42)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [AppColors.normalPrimary, Color(0xFFD65668)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final secondaryGradient = isAfterDark
        ? const LinearGradient(
            colors: [AppColors.darkCard, AppColors.darkBorder],
          )
        : const LinearGradient(
            colors: [Color(0xFFFFF0F3), Color(0xFFFFE3E8)],
          );

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: isSecondary ? secondaryGradient : primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSecondary || !isEnabled
              ? null
              : [
                  BoxShadow(
                    color: (isAfterDark ? AppColors.darkPrimary : AppColors.normalPrimary)
                        .withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: child ??
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 20,
                          color: isSecondary
                              ? (isAfterDark ? AppColors.darkText : AppColors.normalPrimary)
                              : Colors.white,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (text != null)
                        Text(
                          text!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSecondary
                                ? (isAfterDark ? AppColors.darkText : AppColors.normalPrimary)
                                : Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }
}