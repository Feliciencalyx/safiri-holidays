import 'package:material_ui/material_ui.dart';
import '../constants/app_colors.dart';

enum SafiriButtonVariant { primary, secondary, outlined, text }

class SafiriButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final SafiriButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;

  const SafiriButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = SafiriButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget childWidget = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == SafiriButtonVariant.primary ? Colors.white : AppColors.primaryNavy,
            ),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    BorderRadius borderRadius = BorderRadius.circular(4.0);

    switch (variant) {
      case SafiriButtonVariant.primary:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimaryAccent : AppColors.primaryNavy,
              foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: childWidget,
          ),
        );
      case SafiriButtonVariant.secondary:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkCardSurface : const Color(0xFFE8EEF9),
              foregroundColor: isDark ? AppColors.darkPrimaryAccent : AppColors.primaryNavy,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: childWidget,
          ),
        );
      case SafiriButtonVariant.outlined:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.darkPrimaryAccent : AppColors.primaryNavy,
              side: BorderSide(
                color: isDark ? AppColors.darkPrimaryAccent : AppColors.primaryNavy,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: childWidget,
          ),
        );
      case SafiriButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: isDark ? AppColors.darkPrimaryAccent : AppColors.primaryNavy,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: childWidget,
        );
    }
  }
}
