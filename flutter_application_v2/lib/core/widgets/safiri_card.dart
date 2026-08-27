import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SafiriCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const SafiriCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 8.0,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface;
    final defaultBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final cardContent = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? defaultBorder,
          width: 1,
        ),
        boxShadow: boxShadow ?? (isDark
            ? const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.2), blurRadius: 12, offset: Offset(0, 4))]
            : const [BoxShadow(color: Color.fromRGBO(36, 60, 128, 0.06), blurRadius: 16, offset: Offset(0, 6))]),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
