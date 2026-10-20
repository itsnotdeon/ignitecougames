import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Border? border;
  final double borderRadius;
  final Color? backgroundColor;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.border,
    this.borderRadius = 20,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isAfterDark = context.watch<AppProvider>().isAfterDark;

    final bgColor = backgroundColor ??
        (isAfterDark ? AppColors.darkCard : AppColors.normalCard);

    final defaultBorder = border ??
        Border.all(
          color: isAfterDark ? AppColors.darkBorder : AppColors.normalBorder,
          width: 1,
        );

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: defaultBorder,
        boxShadow: [
          BoxShadow(
            color: isAfterDark
                ? Colors.black.withOpacity(0.3)
                : AppColors.normalBorder.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}