import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum ButtonType { primary, secondary, ghost, danger }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color getBgColor() {
      switch (type) {
        case ButtonType.primary: return AppTheme.primary;
        case ButtonType.secondary: return AppTheme.secondary.withAlpha(isDark ? 50 : 30);
        case ButtonType.ghost: return Colors.transparent;
        case ButtonType.danger: return Colors.redAccent.withAlpha(isDark ? 50 : 30);
      }
    }

    Color getTextColor() {
      if (onPressed == null) return Colors.grey;
      switch (type) {
        case ButtonType.primary: return Colors.white;
        case ButtonType.secondary: return AppTheme.secondary;
        case ButtonType.ghost: return AppTheme.primary;
        case ButtonType.danger: return Colors.redAccent;
      }
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: getBgColor(),
          foregroundColor: getTextColor(),
          elevation: type == ButtonType.primary ? 4 : 0,
          shadowColor: type == ButtonType.primary ? AppTheme.primary.withAlpha(100) : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            side: type == ButtonType.ghost 
                ? const BorderSide(color: AppTheme.primary, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}
